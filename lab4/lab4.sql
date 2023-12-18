SET FOREIGN_KEY_CHECKS=0;

DROP TABLE IF EXISTS airport;
DROP TABLE IF EXISTS booking;
DROP TABLE IF EXISTS contactpassenger;
DROP TABLE IF EXISTS creditcard;
DROP TABLE IF EXISTS flight;
DROP TABLE IF EXISTS ispartof;
DROP TABLE IF EXISTS passenger;
DROP TABLE IF EXISTS reservation;
DROP TABLE IF EXISTS route;
DROP TABLE IF EXISTS ticket;
DROP TABLE IF EXISTS weekday;
DROP TABLE IF EXISTS weekschedule;
DROP TABLE IF EXISTS year;

DROP PROCEDURE IF EXISTS addDay
DROP PROCEDURE IF EXISTS addYear
DROP PROCEDURE IF EXISTS addDestination
DROP PROCEDURE IF EXISTS addRoute
DROP PROCEDURE IF EXISTS addFlight

SET FOREIGN_KEY_CHECKS=1;

create table airport
(
    IATA    varchar(3)  not null
        primary key,
    Name    varchar(30) null,
    City    varchar(30) null,
    Country varchar(30) null
)
    comment 'The porting of the air';

create table creditcard
(
    CardNumber bigint      not null
        primary key,
    FirstName  varchar(30) null,
    LastName   varchar(30) null
);

create table flight
(
    WeekdaySchedule int null,
    FlightNumber    int auto_increment
        primary key,
    WeekNr          int null
);

create table passenger
(
    PassportNumber int         not null
        primary key,
    Firstname      varchar(30) null,
    Lastname       varchar(30) null
);

create table contactpassenger
(
    Passenger   int         not null
        primary key,
    Email       varchar(30) null,
    PhoneNumber bigint      null,
    constraint ContactPassenger_passenger_PassportNumber_fk
        foreign key (Passenger) references passenger (PassportNumber)
);

create table reservation
(
    ReservationNumber int    not null
        primary key,
    Price             double null,
    Flight            int    null,
    ContactPassenger  int    null,
    constraint reservation_contactpassenger_Passenger_fk
        foreign key (ContactPassenger) references contactpassenger (Passenger),
    constraint reservation_flight_FlightNumber_fk
        foreign key (Flight) references flight (FlightNumber)
);

create table booking
(
    Reservation int    not null
        primary key,
    PricePaid   double null,
    CreditCard  bigint null,
    constraint booking_reservation_ReservationNumber_fk
        foreign key (Reservation) references reservation (ReservationNumber)
);

create table ispartof
(
    Reservation int not null,
    Passenger   int not null,
    primary key (Reservation, Passenger),
    constraint ispartof_passenger_PassportNumber_fk
        foreign key (Passenger) references passenger (PassportNumber),
    constraint ispartof_reservation_ReservationNumber_fk
        foreign key (Reservation) references reservation (ReservationNumber)
);

create table ticket
(
    TicketNumber int not null
        primary key,
    Passenger    int null,
    Booking      int null,
    Flight       int null,
    constraint ticket_booking_Reservation_fk
        foreign key (Booking) references booking (Reservation),
    constraint ticket_flight_FlightNumber_fk
        foreign key (Flight) references flight (FlightNumber),
    constraint ticket_passenger_PassportNumber_fk
        foreign key (Passenger) references passenger (PassportNumber)
);

create table year
(
    Year         int    not null
        primary key,
    ProfitFactor double null
);

create table route
(
    RouteID            int        auto_increment
        primary key,
    OriginAirport      varchar(3) null,
    DestinationAirport varchar(3) null,
    Price              double     null,
    year               int        null,
    constraint Route_airport_IATA_fk
        foreign key (OriginAirport) references airport (IATA),
    constraint Route_airport_IATA_fk2
        foreign key (DestinationAirport) references airport (IATA),
    constraint route_year_Year_fk
        foreign key (year) references year (Year)
)
    comment 'The highways in the sky for the planes to drive on';

create table weekday
(
    Name      varchar(30) not null
        primary key,
    DayFactor double      null,
    IsOnYear  int         null,
    constraint weekday_year_Year_fk
        foreign key (IsOnYear) references year (Year)
);

create table weekschedule
(
    WeekScheduleID int         auto_increment
        primary key,
    onDay          varchar(30) null,
    DepartureTime  time        null,
    ProfitFactor   double      null,
    Route          int         null,
    constraint WeekSchedule_route_RouteID_fk
        foreign key (Route) references route (RouteID),
    constraint WeekSchedule_weekday_Name_fk
        foreign key (onDay) references weekday (Name)
);


delimiter //
CREATE PROCEDURE addYear (in year int, in factor double)
BEGIN
    INSERT INTO year (Year, ProfitFactor) VALUES (year, factor);
END;
delimiter ;

delimiter //
CREATE PROCEDURE addDay (in year int, in day VARCHAR(30), in factor double)
BEGIN
    INSERT INTO weekday (Name, DayFactor, IsOnYear) VALUES (day, factor, year);
END;
delimiter ;

delimiter //
CREATE PROCEDURE addDestination (in code VARCHAR(3), in name VARCHAR(30), in country VARCHAR(30))
BEGIN
    INSERT INTO airport (IATA, Name, Country) VALUES (code, name, country);
END;
delimiter ;

delimiter //
CREATE PROCEDURE addRoute (in departure_airport_code VARCHAR(3), in arrival_airport_code VARCHAR(3), in year int, in routeprice double)
BEGIN
    INSERT INTO route (OriginAirport, DestinationAirport, Price, year) VALUES (departure_airport_code, arrival_airport_code, routeprice, year);
END;
delimiter ;

delimiter //
CREATE PROCEDURE addFlight (in departure_airport_code VARCHAR(3), in arrival_airport_code VARCHAR(3), in yearin int, in day VARCHAR(30), in departuretime TIME)
BEGIN
    INSERT INTO weekschedule (onDay, DepartureTime, Route) VALUES (day, departuretime, (SELECT route.RouteID FROM route WHERE DestinationAirport = arrival_airport_code and OriginAirport = departure_airport_code and year = yearin));
    SET @y = LAST_INSERT_ID();
    SET @wnr = 1;
    WHILE @wnr < 53 DO
        INSERT INTO flight (WeekdaySchedule, WeekNr) VALUES (@y, @wnr);
        SET @wnr = @wnr + 1;
    END WHILE;
END;
delimiter ;



/*************************************************************************************
 Question 3, Flight addition interfaces test script.
 This is a test script that tests that the interface of the BryanAir back-end works
 correctly. It simply tests that the interfaces exists for filling the database with
 flightinformation, without acutally checking that they do what they are supposed to. 
 This is done later in the question 7 testscript.
*************************************************************************************/
SELECT "Testing questions for flight addition procedures, i.e. question 3" as "Message";
SELECT "Expected output for all queries are 'Query OK, 1 row affected (0.00 sec)' (where the time might differ)" as "Message";

/*Fill the database with data */
SELECT "Trying to add 2 years" AS "Message";
CALL addYear(2010, 2.3);
CALL addYear(2011, 2.5);
SELECT "Trying to add 4 days" AS "Message";
CALL addDay(2010,"Monday",1);
CALL addDay(2010,"Tuesday",1.5);
CALL addDay(2011,"Saturday",2);
CALL addDay(2011,"Sunday",2.5);
SELECT "Trying to add 2 destinations" AS "Message";
CALL addDestination("MIT","Minas Tirith","Mordor");
CALL addDestination("HOB","Hobbiton","The Shire");
SELECT "Trying to add 4 routes" AS "Message";
CALL addRoute("MIT","HOB",2010,2000);
CALL addRoute("HOB","MIT",2010,1600);
CALL addRoute("MIT","HOB",2011,2100);
CALL addRoute("HOB","MIT",2011,1500);
SELECT "Trying to add 4 weeklyschedule flights" AS "Message";
CALL addFlight("MIT","HOB", 2010, "Monday", "09:00:00");
CALL addFlight("HOB","MIT", 2010, "Tuesday", "10:00:00");
CALL addFlight("MIT","HOB", 2011, "Sunday", "11:00:00");
CALL addFlight("HOB","MIT", 2011, "Sunday", "12:00:00");

SELECT "You are now supposed to have 208 flights in your database. If so, and with reasonable data, it is probably correct and this is further tested for question 7" as "Message";