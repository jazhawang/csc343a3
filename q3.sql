/*  q3.sql 

    Find the average fee charged per dive (including extra charges) 
    for dive sites that are more than half full on average, 
    and for those that are half full or less on average. Consider 
    both weekdays and weekends for which there is booking 
    information. Capacity includes all divers, including monitors,
    at a site at a morning, afternoon, or night dive opportunity. 
*/

CREATE TYPE majority AS ENUM('more', 'less');
DROP TABLE IF EXISTS q3 CASCADE;
CREATE TABLE q3 (
    siteid INT NOT NULL,
    price DECIMAL, -- can be null if no bookings were made
    occupancy majority NOT NULL
);

/* Find the occupancy of the divesites for only the times
   in which there exists a booking. So we are not including the
   whole day in which a booking was made, only the times in
   the day. 
 */
DROP VIEW IF EXISTS DiveSiteOccupancyMinimal CASCADE;
CREATE VIEW DiveSiteOccupancyMinimal AS
SELECT Booking.siteID as divesite,
       Booking.bookingDate as dive_date,
       Booking.divetime as divetime,
       -- plus one for the monitors
       (cast((sum(Booking.id)+1) as decimal)/DiveSites.maxCapacity) 
           as occupancy_rate       
FROM Booking JOIN DiveSites ON (Booking.siteID=DiveSites.id)
GROUP BY Booking.diveTime, 
         Booking.siteID, 
         Booking.bookingDate,
         DiveSites.id;


/* Now, we use DiveSiteOccupancyMinimal to find the occupancy
   of every divesite for every day in which a booking was made.
   This is done by grouping DiveSiteOccupancyMinimal by the date,
   summing all the occupancies, and dividing by 3 (there are 3 time
   periods in a day).
 */
DROP VIEW IF EXISTS DiveSiteOccupancy CASCADE;
CREATE VIEW DiveSiteOccupancy AS
SELECT DiveSiteOccupancyMinimal.divesite as divesite,
       DiveSiteOccupancyMinimal.dive_date as dive_date,
       sum(DiveSiteOccupancyMinimal.occupancy_rate) / 3.0 
          as occupancy_rate
FROM DiveSiteOccupancyMinimal
GROUP BY divesite, dive_date;


/* Find the divesites which are more than half full on 
   average, where the definition of 'half full on average' 
   is given in the problem description. 
*/
DROP VIEW IF EXISTS DiveSiteMoreThanHalfFull CASCADE;
CREATE VIEW DiveSiteMoreThanHalfFull AS
SELECT divesite
FROM DiveSiteOccupancy
GROUP BY divesite
HAVING avg(occupancy_rate)>=0.5;

/* Divesites which are less than half full on average. */
DROP VIEW IF EXISTS DiveSiteLessThanHalfFull CASCADE;
CREATE VIEW DiveSiteLessThanHalfFull AS
SELECT id as divesite FROM DiveSites
EXCEPT SELECT * FROM DiveSiteMoreThanHalfFull;


/* Get all the prices the monitors charge for every booking */
DROP VIEW IF EXISTS BookingPricesMonitors CASCADE;
CREATE VIEW BookingPricesMonitors AS
SELECT Booking.id as booking,
       Booking.siteID as divesite,
       MonitorPricing.pricing as price
FROM Booking 
    -- get the monitor's pricing
    JOIN MonitorPricing ON (
        MonitorPricing.mID=Booking.monitorID and 
        MonitorPricing.diveTime=Booking.diveTime and 
        MonitorPricing.diveType=Booking.diveType and 
        MonitorPricing.diveSite=Booking.siteID
    )
GROUP BY Booking.id, MonitorPricing.pricing;


/* Get all the amount for the extra services for everybooking.
   We are assuming that the extra services cost are a flat fee 
   and do not depend on the number of divers in a booking */
DROP VIEW IF EXISTS BookingPricesServices CASCADE;
CREATE VIEW BookingPricesServices AS
SELECT Booking.id as booking,
       Booking.siteID as divesite,
       SUM(dsServices.price) as price
FROM Booking 
     -- get the extra services' pricing
    JOIN BookingService ON (Booking.id=BookingService.bookingID)
    JOIN dsServices ON (
        BookingService.service=dsServices.service and
        dsServices.sID=Booking.siteID
        )
GROUP BY Booking.id;

/* Get the prices that the divesite charges for the divers
   for every booking. */
DROP VIEW IF EXISTS BookingPricesDivers CASCADE;
CREATE VIEW BookingPricesDivers AS
SELECT Booking.id as booking,
       Booking.siteID as divesite,
       count(BookingDiver.diver) * DiveSites.diverFee as price
FROM Booking
    JOIN BookingDiver ON (Booking.id=BookingDiver.booking)
    JOIN DiveSites ON (DiveSites.id=Booking.siteID)
GROUP BY Booking.id, DiveSites.diverFee;

/* Sum the three previous tables by booking.id to get the 
   total price of every booking. */
DROP VIEW IF EXISTS BookingPrices CASCADE;
CREATE VIEW BookingPrices AS
SELECT allPrices.booking as booking,
       allPrices.divesite as divesite,
       sum(allPrices.price) as price
FROM (
    (SELECT * FROM BookingPricesDivers)
    UNION 
    (SELECT * FROM BookingPricesServices)
    UNION 
    (SELECT * FROM BookingPricesMonitors)
    ) allPrices
GROUP BY allPrices.booking, allPrices.divesite;


/* Use BookingPrices to find the average booking fee for every
   divesite. */
DROP VIEW IF EXISTS AverageDiveSitePrice CASCADE;
CREATE VIEW AverageDiveSitePrice AS
SELECT divesite as divesite,
       avg(price) as price
FROM BookingPrices
GROUP BY BookingPrices.divesite;

/* The answer to q3. We append a column representing if the divesites
   are usually more on less than half full, attach the average 
   booking price info, and union the two tables. */
INSERT INTO q3
SELECT * FROM
((
    SELECT hf.divesite as siteID,
           AverageDiveSitePrice.price as price,
           cast('more' as majority) as occupancy
    FROM DiveSiteMoreThanHalfFull as hf
        LEFT OUTER JOIN AverageDiveSitePrice ON (
            hf.divesite=AverageDiveSitePrice.divesite
        )
) UNION (
    SELECT lf.divesite as siteID,
           AverageDiveSitePrice.price as price,
           cast('less' as majority) as occupancy
    FROM DiveSiteLessThanHalfFull as lf
        LEFT OUTER JOIN AverageDiveSitePrice ON (
            lf.divesite=AverageDiveSitePrice.divesite
        )
)) t;