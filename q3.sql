
/* 
    Find the average fee charged per dive (including extra charges) 
    for dive sites that are more than half full on average, 
    and for those that are half full or less on average. Consider 
    both weekdays and weekends for which there is booking 
    information. Capacity includes all divers, including monitors,
    at a site at a morning, afternoon, or night dive opportunity. 
*/

DROP VIEW IF EXISTS DiveSiteOccupancy CASCADE;
CREATE VIEW DiveSiteOccupancy AS
SELECT Booking.siteID as divesite,
       Booking.bookingDate as dive_date,
       Booking.diveType as divetype,
       (sum(Booking.id)/dsDiveTypes.capacity) as occupancy_rate
FROM Booking JOIN dsDiveTypes ON (
    Booking.siteID=dsDiveTypes.sID and 
    Booking.diveType=dsDiveTypes.diveType
    )
GROUP BY Booking.diveType, Booking.siteID, Booking.bookingDate, dsDiveTypes.capacity;

DROP VIEW IF EXISTS DiveSiteMoreThanHalfFull CASCADE;
CREATE VIEW DiveSiteMoreThanHalfFull AS
SELECT divesite
FROM DiveSiteOccupancy
GROUP BY divesite
HAVING avg(occupancy_rate)>=0.5;

DROP VIEW IF EXISTS DiveSiteLessThanHalfFull CASCADE;
CREATE VIEW DiveSiteLessThanHalfFull AS
SELECT id as divesite FROM DiveSites
EXCEPT SELECT * FROM DiveSiteMoreThanHalfFull;


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

DROP VIEW IF EXISTS BookingPricesServices CASCADE;
CREATE VIEW BookingPricesServices AS
SELECT Booking.id as booking,
       Booking.siteID as divesite,
       SUM(dsServices.price) as price
FROM Booking 
     -- get the extra services' pricing
    JOIN BookingService ON (Booking.id=BookingService.bookingID)
    JOIN dsServices ON (BookingService.service=dsServices.service and dsServices.sID=Booking.siteID)
GROUP BY Booking.id;

DROP VIEW IF EXISTS BookingPricesDivers CASCADE;
CREATE VIEW BookingPricesDivers AS
SELECT Booking.id as booking,
       Booking.siteID as divesite,
       count(BookingDiver.diver) * DiveSites.diverFee as price
FROM Booking
    JOIN BookingDiver ON (Booking.id=BookingDiver.booking)
    JOIN DiveSites ON (DiveSites.id=Booking.siteID)
GROUP BY Booking.id, DiveSites.diverFee;

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

DROP VIEW IF EXISTS AverageDiveSitePrice CASCADE;
CREATE VIEW AverageDiveSitePrice AS
SELECT divesite as divesite,
       avg(price) as price
FROM BookingPrices
GROUP BY BookingPrices.divesite;


/* answer */
DROP VIEW IF EXISTS q3 CASCADE;
CREATE VIEW q3 AS
SELECT * FROM
(
    SELECT DiveSiteMoreThanHalfFull.divesite as siteID,
           AverageDiveSitePrice.price as price,
           'more' as occupancy
    FROM DiveSiteMoreThanHalfFull 
        JOIN AverageDiveSitePrice ON (
            DiveSiteMoreThanHalfFull.divesite=AverageDiveSitePrice.divesite
        )
) AS t UNION (
    SELECT DiveSiteLessThanHalfFull.divesite as siteID,
           AverageDiveSitePrice.price as price,
           'less' as occupancy
    FROM DiveSiteLessThanHalfFull 
        JOIN AverageDiveSitePrice ON (
            DiveSiteLessThanHalfFull.divesite=AverageDiveSitePrice.divesite
        )
);