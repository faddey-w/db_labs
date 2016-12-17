
SELECT (@train_run_id:=id) FROM TrainRun LIMIT 1;
SET @start_station_id = 1;
SET @start_date = '2016-12-22';


-- Выбирает все рейсы, которые отправляются из заданной станции в заданный день
SELECT id FROM TrainRun
INNER JOIN RouteStation ON RouteStation.route_id = TrainRun.route_id
WHERE
    DATE(TrainRun.start_dt) = @start_date
    AND RouteStation.station_id = @start_station_id
    AND RouteStation.ordering = (
        SELECT IF(TrainRun.is_reverse, MAX(NestedRouteStation.ordering), MIN(NestedRouteStation.ordering))
        FROM RouteStation as NestedRouteStation
        WHERE RouteStation.route_id = NestedRouteStation.route_id
    );


-- Вывод рейсов и времени их прибытия на конечную станцию
SELECT id, start_dt, (
    SELECT start_dt + INTERVAL MAX(IF(is_reverse, mins_from_end, mins_from_start)) MINUTE
    FROM RouteStation
    WHERE RouteStation.route_id = TrainRun.route_id
) AS arrival_dt FROM TrainRun;

-- То же самое, но без подзапроса
SELECT TrainRun.id, start_dt, (
    start_dt + INTERVAL MAX(IF(is_reverse, mins_from_end, mins_from_start)) MINUTE
) AS arrival_dt FROM TrainRun
INNER JOIN RouteStation ON RouteStation.route_id = TrainRun.route_id
GROUP BY TrainRun.id;


-- Возвращает самый первый рейс, который отправляется из заданной станции в заданный день
SELECT id FROM TrainRun
INNER JOIN RouteStation ON RouteStation.route_id = TrainRun.route_id
WHERE
    DATE(TrainRun.start_dt) = @start_date
    AND RouteStation.station_id = @start_station_id
    AND RouteStation.ordering = (
        SELECT IF(TrainRun.is_reverse, MAX(NestedRouteStation.ordering), MIN(NestedRouteStation.ordering))
        FROM RouteStation as NestedRouteStation
        WHERE RouteStation.route_id = NestedRouteStation.route_id
    )
    AND TIME(start_dt) = (
        SELECT MIN(TIME(start_dt)) FROM TrainRun
        WHERE DATE(start_dt) = @start_date
    );


-- Возвращает все занятые места на заданном отрезке пути заданного рейса
-- важный запрос с практической точки зрения, но без подзапросов
SET @start_station_idx = 1;
SET @end_station_idx = 0;
SELECT seat_id FROM Ticket
INNER JOIN TrainRun
    ON TrainRun.id = Ticket.train_run_id
INNER JOIN RouteStation AS DepartureRouteStation
    ON  DepartureRouteStation.station_id = Ticket.from_station_id
    AND DepartureRouteStation.route_id = TrainRun.route_id
INNER JOIN RouteStation AS ArrivalRouteStation
    ON  ArrivalRouteStation.station_id = Ticket.to_station_id
    AND ArrivalRouteStation.route_id = TrainRun.route_id
WHERE Ticket.train_run_id = @train_run_id
    AND (
        (NOT TrainRun.is_reverse
         AND DepartureRouteStation.ordering < @end_station_idx
         AND ArrivalRouteStation.ordering > @start_station_idx)
    OR (TrainRun.is_reverse
        AND DepartureRouteStation.ordering > @end_station_idx
        AND ArrivalRouteStation.ordering < @start_station_idx)
    );
