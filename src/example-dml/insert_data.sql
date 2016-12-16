
INSERT INTO Station (name)
VALUES
    ('Киев'),
    ('Дарница'),
    ('Львов'),
    ('Фастов'),
    ('Коростень'),
    ('Винница');


INSERT INTO Train (model_name, type, num_seats)
VALUES
    ('ТА-25', 'дизель', 600),
    ('Hundai', 'скоростной', 450),
    ('УМ-104', 'пассажирский', 960);


INSERT INTO Route (identifier)
VALUES
    ('070'),
    ('743'),
    ('141');


-- нужно получить идентификаторы маршрутов и станций
-- чтобы заполнить таблицу станций-на-маршрутах
SELECT (@kiev_id:=id)     FROM Station WHERE name='Киев';
SELECT (@darnitsa_id:=id) FROM Station WHERE name='Дарница';
SELECT (@lvov_id:=id)     FROM Station WHERE name='Львов';
SELECT (@fastov_id:=id)   FROM Station WHERE name='Фастов';
SELECT (@korosten_id:=id) FROM Station WHERE name='Коростень';
SELECT (@vinnista_id:=id) FROM Station WHERE name='Винница';
SELECT (@lvov_vinnitsa_r_id:=id) FROM Route WHERE identifier='070';
SELECT (@kiev_vinnitsa_r_id:=id) FROM Route WHERE identifier='141';
SELECT (@kiev_lvov_r_id:=id)     FROM Route WHERE identifier='743';

INSERT INTO RouteStation(route_id, station_id, ordering, mins_from_start, mins_from_end)
VALUES
    (@lvov_vinnitsa_r_id, @lvov_id,     0, 0,   420),
    (@lvov_vinnitsa_r_id, @vinnista_id, 1, 420, 0),

    (@kiev_vinnitsa_r_id, @kiev_id,     0, 0,   140),
    (@kiev_vinnitsa_r_id, @fastov_id,   1, 60,  80),
    (@kiev_vinnitsa_r_id, @vinnista_id, 2, 140, 0),

    (@kiev_lvov_r_id,     @darnitsa_id, 0, 0,   315),
    (@kiev_lvov_r_id,     @kiev_id,     1, 15,  300),
    (@kiev_lvov_r_id,     @korosten_id, 2, 165, 150),
    (@kiev_lvov_r_id,     @lvov_id,     3, 315, 0);


SELECT (@intercity_id:=id) FROM Train WHERE model_name='Hundai';


INSERT INTO TrainRun(route_id, train_id, start_dt, is_reverse)
VALUES
    (@kiev_vinnitsa_r_id, @intercity_id, '2016-12-22 16:17:00', true);

SELECT (@train_run_id:=id) FROM TrainRun;


INSERT INTO Ticket(train_run_id, passenger_first_name, passenger_last_name,
                   from_station_id, to_station_id, seat_id)
VALUES
    (@train_run_id, 'Вася',     'Пупкин',          @vinnista_id, @kiev_id,   1),
    (@train_run_id, 'Валентин', 'Безбилетный',     @vinnista_id, @fastov_id, 2),
    (@train_run_id, 'Лягушка',  'Путешественница', @fastov_id,   @kiev_id,   2);
