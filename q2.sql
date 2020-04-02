-- Q2. Refunds!

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO wetworldschema;
DROP TABLE IF EXISTS q2 CASCADE;

CREATE TABLE q2 (
    siteID INT NOT NULL,
		monitorID INT NOT NULL,
		maxRating INT NOT NULL
);

-- Do this for each of the views that define your intermediate steps.
-- (But give them better names!) The IF EXISTS avoids generating an error
-- the first time this file is imported.
-- Define views for your intermediate steps here:

-- Get the average rating for each monitor at each location (and their corre
-- -sponding information such as email address)

DROP VIEW IF EXISTS avgRatings CASCADE;
CREATE VIEW avgRatings AS
	select monitorID, avg(monitorRating) as avgRating, emailAddress
	from booking
	group by monitorID, emailAddress;

-- Get the average prices that each monitor charges across all divesites and
-- divetypes

DROP VIEW IF EXISTS avgMonitorPrice CASCADE;
CREATE VIEW avgMonitorPrice AS
	select monitorID, avg(pricing) as avgPrice
	from MonitorPricing
	group by monitorID;

-- Find the highest rated monitor for each location
DROP VIEW IF EXISTS maxRating CASCADE;
CREATE VIEW maxRating AS
	select monitorID, max(avgRating), siteID, emailAddress
	from avgRatings
	group by monitorID, siteID, emailAddress;

DROP VIEW IF EXISTS maxRatingMonitorPrice CASCADE;
CREATE VIEW maxRatingMonitorPrice AS
	select m.monitorID as mID, m.emailAddress as email, a.avgPrice as price
	from maxRating as m, avgMonitorPrice as a
	where m.monitorID = a.monitorID


-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q2
select code as airline, name, year, seat_class, cast(sum(refund) as int)
from Total_Refund
group by code, name, year, seat_class;

select *
from q2;
