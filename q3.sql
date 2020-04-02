
/* 
    Find the average fee charged per dive (including extra charges) 
    for dive sites that are more than half full on average, 
    and for those that are half full or less on average. Consider 
    both weekdays and weekends for which there is booking 
    information. Capacity includes all divers, including monitors,
    at a site at a morning, afternoon, or night dive opportunity. 
*/


CREATE VIEW DiveSiteOccupancy AS
SELECT Booking.siteID as divesite,
       Booking.bookingDate as dive_date,
       Booking.diveType as divetype,
       (sum(Booking.occupancy)/dsDiveTypes.capacity) as occupancy_rate
FROM Booking JOIN dsDiveTypes ON (
    Booking.siteID=dsDiveTypes.sID and 
    Booking.diveType=dsDiveTypes.diveType
    )
GROUP BY Booking.diveType, Booking.siteID, Booking.bookingDate

CREATE VIEW DiveSiteMoreThanHalfFull AS
SELECT divesite 
FROM DiveSiteOccupancy
GROUP BY divesite
HAVING avg(occupancy)>=0.5;

CREATE VIEW DiveSiteLessThanHalfFull AS
SELECT * FROM (SELECT divesite FROM DiveSites) - DiveSiteMoreThanHalfFull;

CREATE VIEW BookingPrices AS
SELECT Booking.id as booking,
       Booking.siteID as divesite,
       MonitorPricing.pricing + sum(dsServices.price) as price
FROM Booking 
    JOIN MonitorPricing ON (
        MonitorPricing.mID=Booking.monitorID and 
        MonitorPricing.diveTime=Booking.diveTime and 
        MonitorPricing.diveType=Booking.diveType and 
        MonitorPricing.diveSite=Booking.siteID
    )
    JOIN BookingService ON (Booking.id=BookingService.bookingID)
    JOIN dsServices ON (BookingService.service=dsServices.service)
GROUP BY Booking.id;


CREATE VIEW AverageDiveSitePrice AS
SELECT divesite as divesite,
       avg(price) as price
FROM BookingPrices
GROUP BY BookingPrices.divesite;


/* answer */
(
    SELECT DiveSiteMoreThanHalfFull.siteID as siteID,
           AverageDiveSitePrice.price as price,
           'more' as occupancy
    FROM DiveSiteMoreThanHalfFull 
        JOIN AverageDiveSitePrices ON (
            DiveSiteMoreThanHalfFull.divesite=AverageDiveSitePrices.divesite
        )
) UNION (
    SELECT DiveSiteLessThanHalfFull.siteID as siteID,
           AverageDiveSitePrice.price as price,
           'less' as occupancy
    FROM DiveSiteLessThanHalfFull 
        JOIN AverageDiveSitePrices ON (
            DiveSiteLessThanHalfFull.divesite=AverageDiveSitePrices.divesite
        )
);