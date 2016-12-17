
-- Перераспределить вагоны по поездам пропорционально нагрузке
SET @total_seats = (SELECT SUM(num_seats) FROM Train);
UPDATE Train
SET num_seats = IFNULL((
    SELECT this_train_tickets.count * @total_seats / all_tickets.count
    FROM (
        SELECT COUNT(*) AS count, TrainRun.train_id AS train_id FROM Ticket
        INNER JOIN TrainRun ON Ticket.train_run_id = TrainRun.id
        GROUP BY TrainRun.train_id
    ) AS this_train_tickets, (
        SELECT COUNT(*) AS count FROM Ticket
    ) as all_tickets
    WHERE this_train_tickets.train_id = Train.id
), 0);


-- Отсоединить последний вагон от всех поездов, где он не занят
UPDATE Train
SET num_seats = num_seats-100
WHERE NOT EXISTS(
    SELECT * FROM Ticket
    INNER JOIN TrainRun ON TrainRun.id = Ticket.train_run_id
    WHERE TrainRun.train_id = Train.id
        AND Ticket.seat_id >= Train.num_seats-100
        AND Train.num_seats > 100
) AND Train.num_seats > 100;


-- Отменить все рейсы, проходящие через указанную станцию
SET @blocked_station_id = 12;
DELETE FROM TrainRun
WHERE @blocked_station_id = ANY(
    SELECT station_id FROM RouteStation
    WHERE RouteStation.route_id = TrainRun.route_id
);



-- Добавляет в базу новый билет, автоматически присваивая ему свободное место.
-- Предполагается, что такое место существует.
SET @train_run_id = 2;
SET @from_station_id = 12;
SET @to_station_id = 7;
INSERT INTO Ticket(train_run_id, passenger_first_name, passenger_last_name,
                   from_station_id, to_station_id, seat_id)
VALUES (
    @train_run_id,
    'Какой-то', 'Пассажир',
    @from_station_id, @to_station_id,
    -- для упрощения запросов я предполагаю, что можно купить билет только из конца в конец
    -- без этого требования запросы стали бы большими, но суть не изменилась бы.
    -- Итак, занятые места могут быть расположены подряд. В таком случае они
    -- занимают индексы [0..N-1], где N - число занятых мест. Значит, мы можем посчитать
    -- число занятых мест и проверить, занято ли место индексом, равным полученному числу.
    -- Если свободно - то это и есть свободное место, которое можно занять.
    -- Если не свободно, то значит в последовательности занятых мест есть дыры.
    -- Как найти любую такую дыру? Взять последовательность занятных индексов, упорядочить.
    -- Пронумеровать начиная с нуля. Взять первый номер, где номер отличается от индекса места.
    -- Если бы в MySQL можно было сгенерировать последовательность чисел заданной длины,
    -- можно было бы сделать гораздо проще.
    SELECT IF(
        EXISTS(
            SELECT * FROM Ticket WHERE train_run_id = @train_run_id AND seat_id = dense.result
        ),
        (
            SELECT (@idx:=@idx+1), seat_id FROM Ticket, (SELECT @idx:=-1) AS Indices
            WHERE @idx != seat_id AND train_run_id = @train_run_id
            ORDER BY seat_id
            LIMIT 1
        ),
        dense.result
    )
    FROM (SELECT COUNT(*) AS result FROM Ticket WHERE train_run_id = @train_run_id) as dense
);
