-- Q2. Refunds!

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO air_travel, public;
DROP TABLE IF EXISTS q2 CASCADE;

CREATE TABLE q2 (
    airline CHAR(2),
    name VARCHAR(50),
    year CHAR(4),
    seat_class seat_class,
    refund REAL
);

-- Do this for each of the views that define your intermediate steps.
-- (But give them better names!) The IF EXISTS avoids generating an error
-- the first time this file is imported.
-- Define views for your intermediate steps here:

-- Flight that do not have to refund

DROP VIEW IF EXISTS Domestic_Flight CASCADE;
CREATE VIEW Domestic_Flight AS
	select f1.id as id, f1.airline as airline, f1.s_dep as s_dep
		, f1.s_arv as s_arv
	from Flight as f1, Airport as a1, Airport as a2
	where a1.code = f1.outbound and a2.code = f1.inbound
		and a1.country = a2.country and f1.id not in (select f2.id
	from Flight as f2, Arrival as a, Departure as d
	where f2.id = d.flight_id and f2.id = a.flight_id
		and (date_part('hour', a.datetime - f2.s_arv) <
		0.5 * date_part('hour', d.datetime - f2.s_dep)));

DROP VIEW IF EXISTS International_Flight CASCADE;
CREATE VIEW International_Flight AS
	select f1.id as id, f1.airline as airline, f1.s_dep as s_dep
		, f1.s_arv as s_arv
	from Flight as f1, Airport as a1, Airport as a2
	where a1.code = f1.outbound and a2.code = f1.inbound
		and a1.country != a2.country and f1.id not in (select f2.id
	from Flight as f2, Arrival as a, Departure as d
	where f2.id = d.flight_id and f2.id = a.flight_id
		and (date_part('hour', a.datetime - f2.s_arv) <
		0.5 * date_part('hour', d.datetime - f2.s_dep)));

DROP VIEW IF EXISTS Delay_Four CASCADE;
CREATE VIEW Delay_Four AS
	select f.id as id, f.airline as airline, date_part('year', f.s_dep) as year
	from Domestic_Flight as f, Departure as d
	where f.id = d.flight_id
		and (date_part('hour', d.datetime) - date_part('hour', f.s_dep) >= 4);

DROP VIEW IF EXISTS Delay_Ten CASCADE;
CREATE VIEW Delay_Ten AS
	select f.id as id, f.airline as airline, date_part('year', f.s_dep) as year
	from Domestic_Flight as f, Departure as d
	where f.id = d.flight_id
		and (date_part('hour', d.datetime) - date_part('hour', f.s_dep) >= 10);

DROP VIEW IF EXISTS Delay_Four_to_Ten CASCADE;
CREATE VIEW Delay_Four_to_Ten AS
	(select * from Delay_Four) except (select * from Delay_Ten);

DROP VIEW IF EXISTS Delay_Seven CASCADE;
CREATE VIEW Delay_Seven AS
	select f.id as id, f.airline as airline, date_part('year', f.s_dep) as year
	from International_Flight as f, Departure as d
	where f.id = d.flight_id
		and (date_part('hour', d.datetime) - date_part('hour', f.s_dep) >= 7);


DROP VIEW IF EXISTS Delay_Twelve CASCADE;
CREATE VIEW Delay_Twelve AS
	select f.id as id, f.airline as airline, date_part('year', f.s_dep) as year
	from International_Flight as f, Departure as d
	where f.id = d.flight_id
		and (date_part('hour', d.datetime) - date_part('hour', f.s_dep) >= 12);

DROP VIEW IF EXISTS Delay_Seven_to_Twelve CASCADE;
CREATE VIEW Delay_Seven_to_Twelve AS
	(select * from Delay_Seven) except (select * from Delay_Twelve);

-- Calculate Refund for each delayed flight
DROP VIEW IF EXISTS Delay_Four_to_Ten_Refund CASCADE;
CREATE VIEW Delay_Four_to_Ten_Refund AS
	select a.code as code, a.name as name, f.year as year
		, b.seat_class as seat_class, sum(b.price * 0.35) as refund
	from Delay_Four_to_Ten as f, Booking as b, airline as a
	where f.id = b.flight_id and f.airline = a.code
	group by a.code, f.year, b.seat_class;

DROP VIEW IF EXISTS Delay_Ten_Refund CASCADE;
CREATE VIEW Delay_Ten_Refund AS
	select a.code as code, a.name as name, f.year as year
		, b.seat_class as seat_class, sum(b.price * 0.5) as refund
	from Delay_Ten as f, Booking as b, airline as a
	where f.id = b.flight_id and f.airline = a.code
	group by a.code, f.year, b.seat_class;

DROP VIEW IF EXISTS Delay_Seven_to_Twelve_Refund CASCADE;
CREATE VIEW Delay_Seven_to_Twelve_Refund AS
	select a.code as code, a.name as name
		, f.year as year, b.seat_class as seat_class, sum(b.price * 0.35) as refund
	from Delay_Seven_to_Twelve as f, Booking as b, airline as a
	where f.id = b.flight_id and f.airline = a.code
	group by a.code, f.year, b.seat_class;

DROP VIEW IF EXISTS Delay_Twelve_Refund CASCADE;
CREATE VIEW Delay_Twelve_Refund AS
	select a.code as code, a.name as name
		, f.year as year, b.seat_class as seat_class, sum(b.price * 0.5) as refund
	from Delay_Twelve as f, Booking as b, airline as a
	where f.id = b.flight_id and f.airline = a.code
	group by a.code, f.year, b.seat_class;

DROP VIEW IF EXISTS Total_Refund CASCADE;
CREATE VIEW Total_Refund AS
	(select * from Delay_Four_to_Ten_Refund)
	union all (select * from Delay_Ten_Refund)
	union all (select * from Delay_Seven_to_Twelve_Refund) 
	union all (select * from Delay_Twelve_Refund);


-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q2
select code as airline, name, year, seat_class, cast(sum(refund) as int)
from Total_Refund
group by code, name, year, seat_class;

select *
from q2;
