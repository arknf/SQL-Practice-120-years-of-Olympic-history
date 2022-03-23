USE olympics_history;

CREATE TABLE athlete_events(
	ID int,
    Name varchar(1000),
    Sex varchar(10),
    Age int,
    Height int,
    Weight int,
    Team varchar(1000),
    NOC varchar(5),
    Games varchar(100),
    Year int,
    Season varchar(100),
    City varchar(100),
    Sport varchar(100),
    Event varchar(100),
    Medal varchar(100)
)