-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO wetworldschema;
DROP TABLE IF EXISTS q2 CASCADE;

CREATE TABLE q2 (
		monitorID INT NOT NULL,
		avgFee INT NOT NULL,
		emailAddress varchar(255) not null
);

-- Do this for each of the views that define your intermediate steps.
-- (But give them better names!) The IF EXISTS avoids generating an error
-- the first time this file is imported.
-- Define views for your intermediate steps here:

-- Get the average rating for each monitor at each location (and their corre
-- -sponding information such as email address)

DROP VIEW IF EXISTS AvgMRatings CASCADE;
CREATE VIEW AvgMRatings AS
	select monitorID, avg(monitorRating) as avgRating
	from booking
	group by monitorID;

-- Get the average rating at each location

DROP VIEW IF EXISTS AvgSRatings CASCADE;
CREATE VIEW AvgSRatings AS
	select siteID, avg(monitorRating) as avgRating
	from booking
	group by siteID;

-- Get all the locations that a monitor dives at

DROP VIEW IF EXISTS MonitorAllLocations CASCADE;
CREATE VIEW MonitorAllLocations AS
	select distinct mID, diveSite
	from MonitorPricing;

-- Combine the average ratings of each monitor with the locations
-- and the ratings of those locations

DROP VIEW IF EXISTS MonitorSiteRatings CASCADE;
CREATE VIEW MonitorSiteRatings AS
	select m.monitorID as mID, m.avgRating as avgMonitorRating,
		s.avgRating as avgSiteRating
	from AvgMRatings as m, AvgSRatings as s, MonitorAllLocations as a
	where m.monitorID = a.mID and a.diveSite = s.siteID;

-- Filter out the monitors that have at least a lower average rating than a
-- specific location

DROP VIEW IF EXISTS BadMonitors CASCADE;
CREATE VIEW BadMonitors AS
	select distinct m.mID
	from MonitorSiteRatings as m
	where m.avgMonitorRating < m.avgSiteRating;

-- Find the monitors that are on average better than all their locations

DROP VIEW IF EXISTS GoodMonitors CASCADE;
CREATE VIEW GoodMonitors AS
	select distinct m.mID as mID, b.id as bID, d.email as email
	from MonitorSiteRatings as m, Booking as b, Diver as d
	where mID NOT IN (select * from BadMonitors) and b.monitorID = m.mID and m.mID = d.id;

-- Computing booking prices for each booking

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
	    JOIN DiveSiteService ON (BookingService.service=DiveSiteService.service and DiveSiteService.sID=Booking.siteID)
	GROUP BY Booking.id;

DROP VIEW IF EXISTS BookingPricesDivers CASCADE;
CREATE VIEW BookingPricesDivers AS
	SELECT Booking.id as booking,
	       Booking.siteID as divesite,
	       count(BookingDiver.diver) * DiveSite.diverFee as price
	FROM Booking
	    JOIN BookingDiver ON (Booking.id=BookingDiver.booking)
	    JOIN DiveSite ON (DiveSite.id=Booking.siteID)
	GROUP BY Booking.id, DiveSite.diverFee;

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

-- Combining monitors and booking prices

DROP VIEW IF EXISTS monitorBookingPrices CASCADE;
CREATE VIEW monitorBookingPrices AS
	select g.mID, avg(b.price), g.email
	from GoodMonitors as g, BookingPrices as b
	where g.bID = b.booking
	group by g.mID, g.email;


-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q2
select *
from monitorBookingPrices;

select *
from q2;
