-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO wetworldschema;
DROP TABLE IF EXISTS q2 CASCADE;

CREATE TABLE q2 (
		monitorID INT NOT NULL,

);

-- Do this for each of the views that define your intermediate steps.
-- (But give them better names!) The IF EXISTS avoids generating an error
-- the first time this file is imported.
-- Define views for your intermediate steps here:

-- Get the average rating for each monitor at each location (and their corre
-- -sponding information such as email address)

DROP VIEW IF EXISTS avgmRatings CASCADE;
CREATE VIEW avgmRatings AS
	select monitorID, avg(monitorRating) as avgRating
	from booking
	group by monitorID;

-- Get the average rating at each location

DROP VIEW IF EXISTS avgsRatings CASCADE;
CREATE VIEW avgsRatings AS
	select siteID, avg(monitorRating) as avgRating
	from booking
	group by siteID;

-- Get all the locations that a monitor dives at

DROP VIEW IF EXISTS monitorAllLocations CASCADE;
CREATE VIEW monitorAllLocations AS
	select monitorID, diveSite
	from MonitorPricing;

-- Combine the average ratings of each monitor with the locations
-- and the ratings of those locations

DROP VIEW IF EXISTS monitorSiteRatings CASCADE;
CREATE VIEW monitorSiteRatings AS
	select m.monitorID as mID, m.avgRating as avgMonitorRating,
		s.avgRating as avgSiteRating
	from avgmRatings as m, avgsRatings as s, monitorAllLocations as a
	where m.monitorID = a.monitorID and a.diveSite = s.siteID;

-- Filter out the monitors that have at least a lower average rating than a
-- specific location

DROP VIEW IF EXISTS badMonitors CASCADE;
CREATE VIEW badMonitors AS
	select distinct m.monitorID
	from monitorSiteRatings as m
	where m.avgMonitorRating < m.avgSiteRating;

-- Find the monitors that are on average better than all their locations

DROP VIEW IF EXISTS goodMonitors CASCADE;
CREATE VIEW goodMonitors AS
	select distinct m.monitorID
	from monitorSiteRatings as m
	where NOT EXISTS badMonitors;

-- Find avg booking fee and email addresses accordingly



-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q2
select *
from maxRatingMonitorPrice;

select *
from q2;
