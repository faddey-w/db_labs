
SELECT 'BEFORE' AS '';
SELECT * FROM Train;
SELECT * FROM TrainRun;
SELECT * FROM Ticket;

-- Изменение в расписании движения поезда
UPDATE TrainRun
SET start_dt = start_dt + INTERVAL 1 HOUR
WHERE route_id = (SELECT id FROM Route WHERE identifier = '141');


-- Присоединение вагона к поезду
UPDATE Train
SET num_seats = num_seats + 100
WHERE model_name = 'ТА-25';


-- Пассажир сдает билет
DELETE FROM Ticket
WHERE passenger_first_name = 'Лягушка' AND passenger_last_name = 'Путешественница';


SELECT 'AFTER' AS '';
SELECT * FROM Train;
SELECT * FROM TrainRun;
SELECT * FROM Ticket;
