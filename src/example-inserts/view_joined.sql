SELECT Route.identifier AS route_id, Station.name AS station_name
FROM RouteStation
INNER JOIN Route ON Route.id = route_id
INNER JOIN Station ON Station.id = station_id
ORDER BY route_id, ordering;


SELECT
    Route.identifier as route_id,
    passenger_first_name, passenger_last_name,
    DepartureStation.name as departuare_station_name,
    ArrivalStation.name as arrival_station_name
FROM Ticket
INNER JOIN TrainRun ON TrainRun.id = train_run_id
INNER JOIN Route ON TrainRun.route_id = Route.id
INNER JOIN Station AS DepartureStation ON DepartureStation.id = from_station_id
INNER JOIN Station AS ArrivalStation ON ArrivalStation.id = to_station_id;
