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

CREATE FUNCTION calculateFreeSeats(flightnumber INT)
RETURNS INT
BEGIN
    DECLARE seatsbooked INT;
    DECLARE freeseats INT;
    SET seatsbooked = (SELECT COUNT(*) FROM ticket WHERE ticket.Flight = flightnumber);
    SET freeseats = 40 - seatsbooked;
    RETURN freeseats;
END;

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

    return price;
END;



DELIMITER //
CREATE TRIGGER after_booking_insert
AFTER INSERT ON booking
FOR EACH ROW
BEGIN
  DECLARE passengerCount INT DEFAULT 0;
  DECLARE currentPassenger INT DEFAULT 0;

  SELECT COUNT(*) INTO passengerCount FROM ispartof WHERE Reservation = NEW.Reservation;

  WHILE passengerCount > 0 DO
    SELECT Passenger INTO currentPassenger FROM ispartof WHERE Reservation = NEW.Reservation LIMIT 1;

    INSERT INTO ticket(TicketNumber, Passenger, Booking)
    VALUES (FLOOR(RAND() * 1000000), currentPassenger, NEW.Reservation);

    SET passengerCount = passengerCount - 1;
  END WHILE;
END;
//
DELIMITER ;


delimiter //
CREATE PROCEDURE addReservation (in departure_airport_code VARCHAR(3), in arrival_airport_code VARCHAR(3), in year int, in week INT, in day VARCHAR(30), in departure_time TIME, in number_of_passengers INT, out reservation_number INT)
BEGIN
    DECLARE flight_number INT DEFAULT NULL;
    DECLARE free_seats INT;

    SELECT flight.FlightNumber INTO @flight_number FROM flight 
        LEFT JOIN weekschedule ON weekschedule.WeekScheduleID = flight.WeekdaySchedule
        LEFT JOIN route ON weekschedule.Route = route.RouteID
        LEFT JOIN weekday ON weekschedule.onDay = weekday.Name
        LEFT JOIN year ON weekday.IsOnYear = year.Year
    WHERE route.OriginAirport = departure_airport_code
    AND route.DestinationAirport = arrival_airport_code
    AND weekschedule.onDay = day
    AND weekday.IsOnYear = year
    AND flight.WeekNr = week
    AND weekschedule.DepartureTime = departure_time;

    IF @flight_number IS NULL THEN
        SELECT "There exist no flight for the given route, date and time" AS "Message";
        SET reservation_number = NULL;
    END IF;

    SELECT calculateFreeSeats(@flight_number) INTO @free_seats;

    IF @free_seats < number_of_passengers THEN
        SELECT "There are not enough seats available on the chosen flight" AS "Message";
        SET reservation_number = NULL;
    ELSE
        INSERT INTO reservation (Price, Flight) VALUES (calculatePrice(@flight_number), @flight_number);
        SET reservation_number = LAST_INSERT_ID();
    END IF;
END;
delimiter ;

delimiter //
CREATE PROCEDURE addPassenger (in Reservation_Number INT, in Passport_Number INT, in name VARCHAR(30))
BEGIN

    DECLARE c INT DEFAULT 0;
    DECLARE r INT DEFAULT 0;
    SELECT COUNT(*) INTO c FROM passenger WHERE PassportNumber = Passport_Number;
    IF c = 0 THEN
        INSERT INTO passenger (PassportNumber, FirstName) VALUES (Passport_Number, name);
    END IF;
    SELECT COUNT(*) INTO r FROM reservation WHERE ReservationNumber = Reservation_Number;
    IF r = 0 THEN
        SELECT "The given reservation number does not exist" AS "Message";
    ELSE
        INSERT INTO ispartof (Reservation, Passenger) VALUES (Reservation_Number, Passport_Number);
    END IF;

END;
delimiter ;

delimiter //
CREATE PROCEDURE addContact (in Reservation_Number INT, in Passport_Number INT, in email VARCHAR(30), in phonenumber BIGINT)
BEGIN

    DECLARE p INT DEFAULT 0;
    DECLARE c INT DEFAULT 0;
    DECLARE r INT DEFAULT 0;

    SELECT COUNT(*) INTO p FROM ispartof WHERE Passenger = Passport_Number AND Reservation = Reservation_Number;
    IF c = 0 THEN
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
END;
delimiter ;

delimiter //
CREATE PROCEDURE addPayment (in Reservation_Number INT, in cardholder_name VARCHAR(30), in credit_card_number BIGINT)
BEGIN
    
        DECLARE c INT DEFAULT 0;
        DECLARE r INT DEFAULT 0;
        DECLARE cc INT DEFAULT NULL;
    
        SELECT COUNT(*) INTO c FROM creditcard WHERE CardNumber = credit_card_number;
        IF c = 0 THEN
            INSERT INTO creditcard (CardNumber, FirstName) VALUES (credit_card_number, cardholder_name);
        END IF;

        SELECT COUNT(*), ContactPassenger INTO r, cc FROM reservation WHERE ReservationNumber = Reservation_Number;

        IF r = 0 THEN
            SELECT "The given reservation number does not exist" AS "Message";
        ELSE
            IF cc IS NULL THEN
                SELECT "The given reservation number does not have a contact" AS "Message";
            ELSE
                UPDATE booking SET PricePaid = (SELECT Price FROM reservation WHERE ReservationNumber = Reservation_Number), CreditCard = credit_card_number WHERE Reservation = Reservation_Number;
            END IF;
        END IF;

END;
delimiter ;



/******************************************************************************************
 Question 6, Reservation interfaces test script.
 This is a test script that tests that the interface of the BryanAir back-end works
 correctly. More specifically it tests that the interfaces handling the reservation
 procedures works correctly and give the correct output.
 The test-cases are:
	Test1:  Adding a correct reservation.
	Test2:  Adding a reservation with incorrect flight details. Should print the
		message "There exist no flight for the given route, date and time".
	Test3:  Adding a reservation when there are not enough seats. Should print the
		message "There are not enough seats available on the chosen flight".
	Test4:  Adding a passenger in a correct manner.
	Test5:  Adding a passenger with incorrect reservation number. Should print the
 		message: "The given reservation number does not exist".
	Test6:  Adding a contact in a correct manner.
	Test7:  Adding a contact with incorrect reservation number. Should print the
		message "The given reservation number does not exist".
	Test8:  Adding a contact that is not a passenger on the reservation. Should print
		the message "The person is not a passenger of the reservation".
	Test9:  Making a payment in a correct manner.
	Test10: Making a payment to a reservation with incorrect reservation number.
		Should print the message "The given reservation number does not exist".
	Test11: Making a payment to a reservation with no contact. Should print the message
		"The reservation has no contact yet".
	Test12: Adding a passenger to an already payed reservation. Should print the message
		"The booking has already been payed and no futher passengers can be added".
**********************************************************************************************/
SELECT "Testing answer for 6, handling reservations and bookings" as "Message";
SELECT "Filling database with flights" as "Message";
/*Fill the database with data */
CALL addYear(2010, 2.3);
CALL addDay(2010,"Monday",1);
CALL addDestination("MIT","Minas Tirith","Mordor");
CALL addDestination("HOB","Hobbiton","The Shire");
CALL addRoute("MIT","HOB",2010,2000);
CALL addFlight("MIT","HOB", 2010, "Monday", "09:00:00");
CALL addFlight("MIT","HOB", 2010, "Monday", "21:00:00");

SELECT "Test 1: Adding a reservation, expected OK result" as "Message";
CALL addReservation("MIT","HOB",2010,1,"Monday","09:00:00",3,@a);
SELECT "Check that the reservation number is returned properly (any number will do):" AS "Message",@a AS "Res. number returned";

SELECT "Test 2: Adding a reservation with incorrect flightdetails. Expected answer: There exist no flight for the given route, date and time" as "Message";
CALL addReservation("MIT","HOB",2010,1,"Tuesday","21:00:00",3,@b);

SELECT "Test 3: Adding a reservation when there are not enough seats. Expected answer: There are not enough seats available on the chosen flight" as "Message";
CALL addReservation("MIT","HOB",2010,1,"Monday","09:00:00",61,@c);

SELECT "Test 4.1: Adding a passenger. Expected OK result" as "Message";
CALL addPassenger(@a,00000001,"Frodo Baggins");

SELECT "Test 4.2: Test whether the same passenger can be added to other reservations. For this test, first add another reservation" as "Message";
CALL addReservation("MIT","HOB",2010,1,"Monday","21:00:00",4,@e);
SELECT @e AS "Reservation number";

SELECT "Now testing. Expected OK result" as "Message";
CALL addPassenger(@e,00000001,"Frodo Baggins");

SELECT "Test 5: Adding a passenger with incorrect reservation number. Expected result: The given reservation number does not exist" as "Message";
CALL addPassenger(9999999,00000001,"Frodo Baggins");

SELECT "Test 6: Adding a contact. Expected OK result" as "Message";
CALL addContact(@a,00000001,"frodo@magic.mail",080667989);

SELECT "Test 7: Adding a contact with incorrect reservation number. Expected result: The given reservation number does not exist" as "Message";
CALL addContact(99999,00000001,"frodo@magic.mail",080667989);

SELECT "Test 8: Adding a contact that is not a passenger on the reservation. Expected result: The person is not a passenger of the reservation" as "Message";
CALL addContact(@a,00000099,"frodo@magic.mail",080667989);

SELECT "Test 9: Making a payment. Expected OK result" as "Message";
CALL addPayment (@a, "Gandalf", 6767676767676767);

SELECT "Test 10: Making a payment to a reservation with incorrect reservation number. Expected result: The given reservation number does not exist" as "Message";
CALL addPayment (999999, "Gandalf", 6767676767676767);

SELECT "Test 11: Making a payment to a reservation with no contact. First setting up reservation" as "Message";
CALL addReservation("MIT","HOB",2010,1,"Monday","09:00:00",1,@d);
CALL addPassenger(@d,00000002,"Sam Gamgee");

SELECT "Now testing. Expected result: The reservation has no contact yet" as "Message";
CALL addPayment (@d, "Gandalf", 6767676767676767);

SELECT "Test 12: Adding a passenger to an already payed reservation. Expected result: The booking has already been payed and no futher passengers can be added" as "Message";
CALL addPassenger(@a,00000003,"Merry Pippins");


/******************************************************************************************
 Question 6, Final test to test for check against overbooking, should print the message
	"There are not enough seats available on the flight anymore, deleting reservation".
**********************************************************************************************/


SELECT "Test 13: Testing if an overbooking occurs" as "Message";
SELECT "Preparing the reservation:" as "Message";
/*Fill the database with data */
CALL addReservation("MIT","HOB",2010,1,"Monday","21:00:00",3,@a);
CALL addPassenger(@a,13000001,"Saruman");
CALL addPassenger(@a,13000002,"Orch1");
CALL addPassenger(@a,13000003,"Orch2");
CALL addPassenger(@a,13000004,"Orch3");
CALL addPassenger(@a,13000005,"Orch4");
CALL addPassenger(@a,13000006,"Orch5");
CALL addPassenger(@a,13000007,"Orch6");
CALL addPassenger(@a,13000008,"Orch7");
CALL addPassenger(@a,13000009,"Orch8");
CALL addPassenger(@a,13000010,"Orch9");
CALL addPassenger(@a,13000011,"Orch10");
CALL addPassenger(@a,13000012,"Orch11");
CALL addPassenger(@a,13000013,"Orch12");
CALL addPassenger(@a,13000014,"Orch13");
CALL addPassenger(@a,13000015,"Orch14");
CALL addPassenger(@a,13000016,"Orch15");
CALL addPassenger(@a,13000017,"Orch16");
CALL addPassenger(@a,13000018,"Orch17");
CALL addPassenger(@a,13000019,"Orch18");
CALL addPassenger(@a,13000020,"Orch19");
CALL addPassenger(@a,13000021,"Orch20");
CALL addPassenger(@a,13000022,"Orch21");
CALL addPassenger(@a,13000023,"Orch22");
CALL addPassenger(@a,13000024,"Orch23");
CALL addPassenger(@a,13000025,"Orch24");
CALL addPassenger(@a,13000026,"Orch25");
CALL addPassenger(@a,13000027,"Orch26");
CALL addPassenger(@a,13000028,"Orch27");
CALL addPassenger(@a,13000029,"Orch28");
CALL addPassenger(@a,13000030,"Orch29");
CALL addPassenger(@a,13000031,"Orch30");
CALL addPassenger(@a,13000032,"Orch31");
CALL addPassenger(@a,13000033,"Orch32");
CALL addPassenger(@a,13000034,"Orch33");
CALL addPassenger(@a,13000035,"Orch34");
CALL addPassenger(@a,13000036,"Orch35");
CALL addPassenger(@a,13000037,"Orch36");
CALL addPassenger(@a,13000038,"Orch37");
CALL addPassenger(@a,13000039,"Orch38");
CALL addPassenger(@a,13000040,"Orch39");
CALL addPassenger(@a,13000041,"Orch40");
CALL addContact(@a,13000001,"saruman@magic.mail",080667989);
SELECT "Now testing. Expected result: There are not enough seats available on the flight anymore, deleting reservation" as "Message";
CALL addPayment (@a, "Sauron",7878787878);
