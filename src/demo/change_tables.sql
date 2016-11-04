-- Добавим, например, паспортные данные пассажира
ALTER TABLE Ticket
    ADD COLUMN passenger_passport CHAR(8)
    AFTER passenger_last_name;


-- Пусть у нас имеются еще города, и станции могут принадлежать городам
CREATE TABLE City (
    id SERIAL,
    name VARCHAR(50),
    PRIMARY KEY (id)
);

ALTER TABLE Station
    ADD COLUMN city_id BIGINT UNSIGNED,
    ADD CONSTRAINT station_belongs_to_city
        FOREIGN KEY (city_id) REFERENCES City(id);


-- Добавим индекс по имени станции
-- Это имеет смысл, потому что поиск станции по имени
-- является типичной операцией для этой предметной области
ALTER TABLE Station
    ADD INDEX station_name_index (name);


-- Пусть теперь станции хранятся в кодировке Windows
-- потому что на машинах кассиров установлена Windows
ALTER TABLE Station
    CONVERT TO CHARACTER SET cp1251;


DESCRIBE City;
DESCRIBE Station;
DESCRIBE Ticket;