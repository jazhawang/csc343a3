-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO wetworldschema;
DROP TABLE IF EXISTS q4 CASCADE;

CREATE TABLE q4 (
		diveSite INT NOT NULL,
		highest INT NOT NULL,
		lowest INT NOT NULL,
		avg INT NOT NULL
);

-- Do this for each of the views that define your intermediate steps.
-- (But give them better names!) The IF EXISTS avoids generating an error
-- the first time this file is imported.
-- Define views for your intermediate steps here:

-- Getting the locations and all of the bookings associated with the location

DROP VIEW IF EXISTS locationBookings CASCADE;
CREATE VIEW locationBookings AS
	select *
	from DiveSites as d, Booking as b
	where d.id=b.siteID

-- Intermediate step computing all the possible prices

-- Filter out to take the max, min and avg

-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q4
select *
from maxRatingMonitorPrice;

select *
from q4;
