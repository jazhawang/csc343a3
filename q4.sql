-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO wetworldschema;

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
       SUM(DiveSiteService.price) as price
FROM Booking 
     -- get the extra services' pricing
    JOIN BookingService ON (Booking.id=BookingService.bookingID)
    JOIN DiveSiteService ON (
        BookingService.service=DiveSiteService.service and
        DiveSiteService.sID=Booking.siteID
        )
GROUP BY Booking.id;

DROP VIEW IF EXISTS BookingPricesDivers CASCADE;
CREATE VIEW BookingPricesDivers AS
SELECT Booking.id as booking,
       Booking.siteID as divesite,
       COUNT(BookingDiver.diver) * DiveSite.diverFee as price
FROM Booking
	-- get the dive site per divers fees
    JOIN BookingDiver ON (Booking.id=BookingDiver.booking)
    JOIN DiveSite ON (DiveSite.id=Booking.siteID)
GROUP BY Booking.id, DiveSite.diverFee;


/* Get the total booking prices. For an explanation go to q3.sql */
DROP VIEW IF EXISTS BookingPrices CASCADE;
CREATE VIEW BookingPrices AS
SELECT allPrices.booking as booking,
       allPrices.divesite as divesite,
       SUM(allPrices.price) as price
FROM (
    (SELECT * FROM BookingPricesDivers)
    UNION 
    (SELECT * FROM BookingPricesServices)
    UNION 
    (SELECT * FROM BookingPricesMonitors)
    ) allPrices
GROUP BY allPrices.booking, allPrices.divesite;


DROP TABLE IF EXISTS q4 CASCADE;
CREATE TABLE q4 (
		diveSite INT NOT NULL,
		highest INT,
		lowest INT,
		average INT 
);

/* get the min,max, and avg booking price for every divesite
   we need to left outer join with DiveSite because some divesites 
   may not have any bookings. In that case the max,min, and avg are NULL. */
INSERT INTO q4
SELECT DiveSite.id as diveSite, 
	   MAX(price) as highest,
	   MIN(price) as lowest,
	   AVG(price) as average
FROM DiveSite 
	LEFT OUTER JOIN BookingPrices ON (DiveSite.id=BookingPrices.divesite)
GROUP BY DiveSite.id;
