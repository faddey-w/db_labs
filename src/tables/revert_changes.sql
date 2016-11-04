-- уберем паспортный данные пассажира
ALTER TABLE Ticket
    DROP passenger_passport;


-- Уберем таблицу городов, и соответственно все связи с ней
ALTER TABLE Station
    DROP FOREIGN KEY station_belongs_to_city,
    DROP city_id;
DROP TABLE City;


-- Уберем индекс по имени станции
ALTER TABLE Station
    DROP INDEX station_name_index;


-- Вернем обратно кодировку utf-8
ALTER TABLE Station
    CONVERT TO CHARACTER SET utf8;

DESCRIBE Station;
DESCRIBE Ticket;
