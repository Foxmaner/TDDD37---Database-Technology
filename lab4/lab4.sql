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

DROP PROCEDURE IF EXISTS addDay;
DROP PROCEDURE IF EXISTS addYear;
DROP PROCEDURE IF EXISTS addDestination;
DROP PROCEDURE IF EXISTS addRoute;
DROP PROCEDURE IF EXISTS addFlight;
DROP PROCEDURE IF EXISTS addReservation;
DROP PROCEDURE IF EXISTS addPassenger;
DROP PROCEDURE IF EXISTS addContact;
DROP PROCEDURE IF EXISTS addPayment;

DROP FUNCTION IF EXISTS calculateFreeSeats;
DROP FUNCTION IF EXISTS calculatePrice;

DROP TRIGGER IF EXISTS after_booking_insert;

DROP VIEW IF EXISTS allFlights;

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
    ReservationNumber int    auto_increment
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
//
delimiter ;

delimiter //
CREATE PROCEDURE addDay (in year int, in day VARCHAR(30), in factor double)
BEGIN
    INSERT INTO weekday (Name, DayFactor, IsOnYear) VALUES (day, factor, year);
END;
//
delimiter ;

delimiter //
CREATE PROCEDURE addDestination (in code VARCHAR(3), in name VARCHAR(30), in country VARCHAR(30))
BEGIN
    INSERT INTO airport (IATA, Name, Country) VALUES (code, name, country);
END;
//
delimiter ;

delimiter //
CREATE PROCEDURE addRoute (in departure_airport_code VARCHAR(3), in arrival_airport_code VARCHAR(3), in year int, in routeprice double)
BEGIN
    INSERT INTO route (OriginAirport, DestinationAirport, Price, year) VALUES (departure_airport_code, arrival_airport_code, routeprice, year);
END;
//
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
//
delimiter ;

delimiter //
CREATE FUNCTION calculateFreeSeats(flightnumber INT)
RETURNS INT
BEGIN
    DECLARE freeseats INT DEFAULT 0;
    SELECT 40 - COUNT(*) INTO freeseats FROM ticket
    WHERE Flight = flightnumber;
    /*
    SELECT 40 - COUNT(*) INTO freeseats FROM ispartof
        LEFT JOIN reservation ON reservation.ReservationNumber = ispartof.Reservation
    WHERE reservation.Flight = flightnumber;
    */
    RETURN freeseats;
END;
//
delimiter ;


delimiter //
CREATE FUNCTION calculatePrice(flightnumber INT)
RETURNS DOUBLE
BEGIN
    DECLARE price DOUBLE;
    set price = (SELECT  route.Price * weekday.DayFactor * ((((40 - calculateFreeSeats(flightnumber)) + 1) / 40.0)) * year.ProfitFactor AS p
    FROM weekschedule
       LEFT Join flight ON flight.WeekdaySchedule = weekschedule.WeekScheduleID
       LEFT JOIN route ON weekschedule.Route = route.RouteID
       LEFT JOIN weekday ON weekschedule.onDay = weekday.Name
       LEFT JOIN year ON route.year = year.Year
    WHERE flight.FlightNumber = flightnumber);

    return ROUND(price,3);
END;
//
delimiter ;



DELIMITER //
CREATE TRIGGER after_booking_insert
AFTER INSERT ON booking
FOR EACH ROW
BEGIN
    DECLARE passengerCount INT DEFAULT 0;
    DECLARE currentPassenger INT DEFAULT 0;

    SELECT COUNT(*) INTO passengerCount FROM ispartof WHERE Reservation = NEW.Reservation;

    INSERT INTO ticket (TicketNumber, Passenger, Booking, Flight) 
    SELECT FLOOR(RAND() * 1000000), Passenger, Reservation, reservation.flight 
    FROM ispartof 
        LEFT JOIN reservation ON reservation.ReservationNumber = ispartof.Reservation
    WHERE ispartof.Reservation = NEW.Reservation;

    /*
    WHILE passengerCount > 0 DO
        SELECT Passenger INTO currentPassenger FROM ispartof WHERE Reservation = NEW.Reservation AND Passenger != currentPassenger LIMIT 1;

        INSERT INTO ticket(TicketNumber, Passenger, Booking)
        VALUES (FLOOR(RAND() * 1000000), currentPassenger, NEW.Reservation);

        SET passengerCount = passengerCount - 1;
    END WHILE;
    */
END;
//
DELIMITER ;


delimiter //
CREATE PROCEDURE addReservation (in departure_airport_code VARCHAR(3), in arrival_airport_code VARCHAR(3), in Iyear int, in Iweek INT, in Iday VARCHAR(30), in departure_time TIME, in number_of_passengers INT, out reservation_number INT)
BEGIN
    DECLARE flight_number INT DEFAULT NULL;
    DECLARE free_seats INT;

    SELECT COUNT(flight.FlightNumber) INTO flight_number FROM flight
        LEFT JOIN weekschedule ON weekschedule.WeekScheduleID = flight.WeekdaySchedule
        LEFT JOIN route ON weekschedule.Route = route.RouteID
        LEFT JOIN weekday ON weekschedule.onDay = weekday.Name
        LEFT JOIN year ON weekday.IsOnYear = year.Year
    WHERE route.OriginAirport = departure_airport_code
    AND route.DestinationAirport = arrival_airport_code
    AND weekschedule.onDay = Iday
    AND weekday.IsOnYear = Iyear
    AND flight.WeekNr = Iweek
    AND weekschedule.DepartureTime = departure_time;

    IF flight_number = 0 THEN
        SELECT "There exist no flight for the given route, date and time" AS "Message";
        SET reservation_number = NULL;
    ELSE
        SELECT calculateFreeSeats(flight_number) INTO free_seats;

        IF free_seats < number_of_passengers THEN
            SELECT "There are not enough seats available on the chosen flight" AS "Message";
            SET reservation_number = NULL;
        ELSE
            INSERT INTO reservation (Price, Flight) VALUES (calculatePrice(flight_number), flight_number);
            SET reservation_number = LAST_INSERT_ID();
        END IF;
    END IF;

END;
//
delimiter ;

delimiter //
CREATE PROCEDURE addPassenger (in Reservation_Number INT, in Passport_Number INT, in name VARCHAR(30))
BEGIN

    DECLARE c INT DEFAULT 0;
    DECLARE r INT DEFAULT 0;
    DECLARE isPaid INT DEFAULT 0;
    SELECT COUNT(*) INTO c FROM passenger WHERE PassportNumber = Passport_Number;
    IF c = 0 THEN
        INSERT INTO passenger (PassportNumber, FirstName) VALUES (Passport_Number, name);
    END IF;

    SELECT COUNT(*) INTO r FROM reservation WHERE ReservationNumber = Reservation_Number;
    IF r = 0 THEN
        SELECT "The given reservation number does not exist" AS "Message";
    ELSE
        SELECT COUNT(*) INTO isPaid FROM booking WHERE Reservation = Reservation_Number;
        IF isPaid != 0 THEN
            SELECT "The booking has already been payed and no futher passengers can be added" AS "Message";
        ELSE
            INSERT INTO ispartof (Reservation, Passenger) VALUES (Reservation_Number, Passport_Number);
        END IF;
    END IF;

END;
//
delimiter ;

delimiter //
CREATE PROCEDURE addContact (in Reservation_Number INT, in Passport_Number INT, in email VARCHAR(30), in phonenumber BIGINT)
BEGIN

    DECLARE p INT DEFAULT 0;
    DECLARE c INT DEFAULT 0;
    DECLARE r INT DEFAULT 0;
    DECLARE res INT DEFAULT 0;

    SELECT COUNT(*) INTO p FROM ispartof WHERE Passenger = Passport_Number AND Reservation = Reservation_Number;
    SELECT COUNT(*) INTO res FROM reservation WHERE ReservationNumber = Reservation_Number;
    IF res = 0 THEN
        SELECT "The given reservation number does not exist" AS "Message";
    ELSE
        IF p = 0 THEN
            SELECT "The person is not a passenger of the reservation" AS "Message";
        ELSE
            SELECT COUNT(*) INTO c FROM contactpassenger WHERE Passenger = Passport_Number;
            IF c = 0 THEN
                INSERT INTO contactpassenger (Passenger, Email, PhoneNumber) VALUES (Passport_Number, Email, phonenumber);
            END IF;
            SELECT COUNT(*) INTO r FROM reservation WHERE ReservationNumber = Reservation_Number;
            IF r = 0 THEN
                SELECT "The given reservation number does not exist" AS "Message";
            ELSE
                UPDATE reservation SET ContactPassenger = Passport_Number WHERE ReservationNumber = Reservation_Number;
            END IF;
        END IF;
    END IF;
END;
//
delimiter ;

delimiter //
CREATE PROCEDURE addPayment (in Reservation_Number INT, in cardholder_name VARCHAR(30), in credit_card_number BIGINT)
BEGIN
    DECLARE c INT DEFAULT 0;
    DECLARE r INT DEFAULT 0;
    DECLARE cc INT DEFAULT 0;
    DECLARE isPaid INT DEFAULT 0;
    DECLARE p INT DEFAULT 0;
    DECLARE pp INT DEFAULT 0;

    SELECT COUNT(*) INTO c FROM creditcard WHERE CardNumber = credit_card_number;
    IF c = 0 THEN
        INSERT INTO creditcard (CardNumber, FirstName) VALUES (credit_card_number, cardholder_name);
    END IF;


    SELECT COUNT(*), COUNT(ContactPassenger) INTO r, cc FROM reservation WHERE ReservationNumber = Reservation_Number;

    IF r = 0 THEN
        SELECT "The given reservation number does not exist" AS "Message";
    ELSE
        IF cc = 0 THEN
            SELECT "The reservation has no contact yet" AS "Message";
        ELSE
            SELECT COUNT(*) INTO isPaid FROM booking WHERE Reservation = Reservation_Number;
            IF isPaid != 0 THEN
                SELECT "The booking has already been payed and no futher passengers can be added" AS "Message";
            ELSE
                SELECT COUNT(*), calculateFreeSeats(flight.FlightNumber) 
                INTO p, pp 
                FROM ispartof 
                    LEFT JOIN reservation ON ispartof.Reservation = reservation.ReservationNumber
                    LEFT JOIN flight ON reservation.Flight = flight.FlightNumber
                WHERE Reservation = Reservation_Number;
                IF p <= pp THEN
                    INSERT INTO booking (Reservation, PricePaid, CreditCard) VALUES (Reservation_Number, (SELECT Price FROM reservation WHERE ReservationNumber = Reservation_Number), credit_card_number);
                ELSE
                    DELETE FROM ispartof WHERE Reservation = Reservation_Number;
                    DELETE FROM reservation WHERE ReservationNumber = Reservation_Number;
                    SELECT "There are not enough seats available on the flight anymore, deleting reservation" AS "Message";
                END IF;
            END IF;
        END IF;
    END IF;
END;
//
delimiter ;


delimiter //
CREATE VIEW allFlights AS
SELECT o.Name AS departure_city_name, 
d.Name AS destination_city_name, 
weekschedule.DepartureTime AS departure_time, 
weekschedule.onDay AS departure_day, 
flight.WeekNr AS departure_week, 
weekday.IsOnYear AS departure_year, 
calculateFreeSeats(flight.FlightNumber) AS nr_of_free_seats, 
calculatePrice(flight.FlightNumber) AS current_price_per_seat
FROM flight
    LEFT JOIN weekschedule on flight.WeekdaySchedule = weekschedule.WeekScheduleID
    LEFT JOIN route ON weekschedule.Route = route.RouteID
    LEFT JOIN weekday ON weekschedule.onDay = weekday.Name
    LEFT JOIN airport o ON route.OriginAirport = o.IATA
    LEFT JOIN airport d ON route.DestinationAirport = d.IATA;

//
delimiter ;
