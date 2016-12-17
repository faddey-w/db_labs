-- Станции
CREATE TABLE Station (
    id SERIAL,
    name VARCHAR(50),
    PRIMARY KEY(id)
);

-- Поезда
CREATE TABLE Train (
    id SERIAL,
    model_name VARCHAR(20),
    type ENUM("электропоезд", "дизель", "пассажирский", "скоростной"),
    -- для упрощения допустим, что во всех вагонах равное количество мест
    -- и поэтому можно ввести единую нумерацию мест, и по номеру места
    -- можно определить номер вагона
    num_seats INTEGER UNSIGNED,
    PRIMARY KEY (id)
);

-- Маршруты
CREATE TABLE Route (
    id SERIAL,
    identifier CHAR(3),
    UNIQUE (identifier),
    PRIMARY KEY (id)
);

-- Станции, которые поезд проходит на данном маршруте
CREATE TABLE RouteStation (
    route_id BIGINT UNSIGNED,
    station_id BIGINT UNSIGNED,
    -- необходимо указывать порядок следования станций
    ordering SMALLINT,

    -- как много минут сюда ехать от начала маршрута и от конца соответственно.
    mins_from_start INTEGER,
    mins_from_end INTEGER,

    -- чтобы можно было определить строгий порядок следования
    -- в одном маршруте не должны повторяться индексы порядка
    -- Также логично, что элемент маршрута определяется по его индексу:
    -- таким образом упорядочение по первичному ключу выведет путь в
    -- его естественном порядке.
    PRIMARY KEY (route_id, ordering),
    -- в одном маршруте одна станция не может быть пройдена дважды
    -- на практике это теоретически может оказаться не так, но
    -- данное ограничение значительно упростит определение того,
    -- на каком отрезке пути место в поезде свободно, а на каком - нет
    UNIQUE (route_id, station_id),

    FOREIGN KEY (route_id) REFERENCES Route(id),
    FOREIGN KEY (station_id) REFERENCES Station(id)
);

-- Конкретные поездки
CREATE TABLE TrainRun (
    id SERIAL,
    route_id BIGINT UNSIGNED,
    train_id BIGINT UNSIGNED,

    -- дата и время начала поездки
    start_dt DATETIME,

    -- это поездка в обратном направлении или в прямом
    is_reverse BOOL,

    PRIMARY KEY (id),

    FOREIGN KEY (route_id) REFERENCES Route(id),
    FOREIGN KEY (train_id) REFERENCES Train(id)
);

-- Билет
CREATE TABLE Ticket (
    id SERIAL,
    train_run_id BIGINT UNSIGNED,

    -- данные о пассажире я не вынес в отдельную таблицу, потому что это не нужно
    -- по факту железнодорожные организации не хранят отдельно данные о людях
    -- им лишь нужно, чтобы имя в билете и имя в паспорте совпадали.
    passenger_first_name VARCHAR(50),
    passenger_last_name VARCHAR(50),

    -- Начальная и конечная станции поездки
    from_station_id BIGINT UNSIGNED,
    to_station_id BIGINT UNSIGNED,

    -- номер места
    seat_id INTEGER UNSIGNED,

    PRIMARY KEY (id),


    -- Здесь также имеются некоторые ограничения, которые нельзя выразить внешними ключами
    -- Например, конечная и начальная станции билета должны присутствовать в маршруте
    FOREIGN KEY (train_run_id) REFERENCES TrainRun(id),
    FOREIGN KEY (from_station_id) REFERENCES Station(id),
    FOREIGN KEY (to_station_id) REFERENCES Station(id)
);
