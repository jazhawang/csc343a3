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
       SUM(dsServices.price) as price
FROM Booking 
     -- get the extra services' pricing
    JOIN BookingService ON (Booking.id=BookingService.bookingID)
    JOIN dsServices ON (
        BookingService.service=dsServices.service and
        dsServices.sID=Booking.siteID
        )
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


DROP TABLE IF EXISTS q4 CASCADE;
CREATE TABLE q4 (
		diveSite INT NOT NULL,
		highest INT,
		lowest INT,
		average INT 
);


/* get the min,max, and avg booking price for every divesite
   we need to left outer join with DiveSites because some divesites 
   may not have any bookings. In that case the max,min, and avg are NULL. */
INSERT INTO q4
SELECT Divesites.id as diveSite, 
	   max(price) as highest,
	   min(price) as lowest,
	   avg(price) as average
FROM DiveSites LEFT OUTER JOIN BookingPrices ON (DiveSites.id=BookingPrices.divesite)
GROUP BY Divesites.id;
