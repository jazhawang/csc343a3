/* data.sql */

INSERT INTO DiveSites (id, name, location, diverFee, maxCapacity)
VALUES
    (1, 'Bloody Bay Marine Park', 'Little Cayman', 1000, 10),
    (2, 'Widow Makers Cave', 'Montegro Bay', 2000, 15),
    (3, 'Crystal Bay', 'Crystal Bay', 1500, 10),
    (4, 'Batu Bolong', 'Batu Bolong', 1500, 10);

INSERT INTO dsDiveTypes (sID, diveType, capacity)
VALUES
    (1, 'cave', 10),
    (2, 'open', 15),
    (2, 'cave', 10),
    (3, 'open', 10),
    (3, 'cave', 10),
    (4, 'open', 10),
    (4, 'cave', 10),
    (4, 'deep', 10);

INSERT INTO dsServices (sID, service, price)
VALUES
    (1, 'masks', 500),
    (1, 'fins', 1000),
    (2, 'masks', 300),
    (2, 'fins', 500),
    (3, 'fins', 500),
    (3, 'wrist_mounted_computer', 2000),
    (4, 'masks', 1000),
    (4, 'wrist_mounted_computer', 3000);


-- in our schema, all monitors are divers.
INSERT INTO Diver (id, name, age, certification, email)
VALUES
    -- the ages/certification of the monitors are not defined in data.txt
    -- some other things are not defined, they are the 555 and NA values
    (1, 'Maria', 555, 'NA', 'maria@something.com'),
    (2, 'John', 555, 'NA', 'john@something.com'),
    (3, 'Ben', 555, 'NA', 'ben@something.com'),
    (4, 'Micheal', 53, 'PADI', 'micheal@dm.org'),
    (5, 'Andy', 47 , 'PADI', 'andy@dm.org'),
    (6, 'Dwight Schrute', 555 , 'NA', 'dwight@dm.org'),
    (7, 'Jim Halbert', 555 , 'NA', 'jim@dm.org'),
    (8, 'Pam Beesly', 555 , 'NA', 'pam@dm.org'),
    (9, 'Phyllis', 555 , 'NA', 'NA'),
    (10, 'Oscar', 555 , 'NA', 'NA');


INSERT INTO Monitor (dID, maxCapacity)
VALUES
    (1, 10),
    (2, 15),
    (3, 15);

INSERT INTO MonitorPricing (mID, diveTime, diveType, diveSite, pricing)
VALUES
    (1, 'night', 'cave', 1, 2500),
    (1, 'morning', 'open', 2, 1000),
    (1, 'morning', 'cave', 2, 2000),
    (1, 'afternoon', 'open', 3, 1500),
    (1, 'morning', 'cave', 4, 3000),
    (2, 'morning', 'cave', 1, 1500),
    (3, 'morning', 'cave', 2, 2000);

INSERT INTO MonitorPrivilege (mID, siteID)
VALUES
    (1,1),
    (1,2),
    (1,3),
    (1,4),
    (2,1),
    (2,3),
    (3,2);

INSERT INTO MonitorCapacity (mID, diveType, group_size)
VALUES
    (1, 'open', 10),
    (1, 'cave', 5),
    (1, 'deep', 5),
    (2, 'open', 15),
    (2, 'cave', 15),
    (2, 'deep', 15),
    (3, 'open', 15),
    (3, 'cave', 5),
    (3, 'deep', 5);

INSERT INTO Booking (id, monitorID, leadID, siteID, creditCardInfo, diveTime, diveType, bookingDate, monitorRating)
VALUES
    (1, 1, 4, 2, 'XXXXXX', 'morning', 'open', '2019-07-20', 2),
    (2, 1, 4, 2, 'XXXXXX', 'morning', 'cave', '2019-07-21', 2),
    (3, 2, 4, 1, 'XXXXXX', 'morning', 'cave', '2019-07-22', 5),
    (4, 1, 4, 1, 'XXXXXX', 'night', 'cave', '2019-07-22', NULL),
    (5, 1, 5, 3, 'XXXXXX', 'afternoon', 'open', '2019-07-22', 1),
    (6, 3, 5, 2, 'XXXXXX', 'morning', 'cave', '2019-07-23', 1),
    (7, 3, 5, 2, 'XXXXXX', 'morning', 'cave', '2019-07-24', 2);


INSERT INTO BookingService (bookingID, service)
VALUES
    (1, 'masks'),
    (1, 'fins');

INSERT INTO BookingDiver(booking, diver, rating)
VALUES
    (1, 4, NULL),
    (1, 5, NULL),
    (1, 6, NULL),
    (1, 7, NULL),
    (1, 8, NULL),
    (2, 4, NULL),
    (2, 6, NULL),
    (2, 7, NULL),
    (3, 4, NULL),
    (3, 7, NULL),
    (4, 4, NULL),
    (5, 5, NULL),
    (5, 4, NULL),
    (5, 6, NULL),
    (5, 7, NULL),
    (5, 9, NULL),
    (5, 8, NULL),
    (5, 10, NULL),
    (6, 5, NULL),
    (7, 5, NULL);
