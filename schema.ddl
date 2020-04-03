
/* Schema for CSC343 A3

  All monetary values are in cents.
*/
drop schema if exists wetworldschema cascade;
create schema wetworldschema;
set search_path to wetworldschema;

/* Types for fixed domain specific information */
CREATE TYPE certification AS ENUM ('NAUI', 'CMAS', 'PADI', 'NA');
CREATE TYPE diveType AS ENUM('open', 'cave', 'deep');
CREATE TYPE diveTime AS ENUM('morning', 'afternoon', 'night');
CREATE TYPE service AS ENUM(
  'video',
  'snacks',
  'hot_showers',
  'towel_service',
  'masks',
  'regulators',
  'fins',
  'wrist_mounted_computer'
  );
/*
DROP TABLE IF EXISTS Diver CASCADE;
DROP TABLE IF EXISTS DiveSite CASCADE;
DROP TABLE IF EXISTS Monitor CASCADE;
DROP TABLE IF EXISTS MonitorPricing CASCADE;
DROP TABLE IF EXISTS MonitorCapacity CASCADE;
DROP TABLE IF EXISTS MonitorPrivilege CASCADE;
DROP TABLE IF EXISTS DiveSiteService CASCADE;
DROP TABLE IF EXISTS DiveSiteDiveType CASCADE;
DROP TABLE IF EXISTS Booking CASCADE;
DROP TABLE IF EXISTS BookingService CASCADE;
DROP TABLE IF EXISTS BookingDiver CASCADE; */


/*
  Contains the crucial information about each diver
*/
CREATE Table Diver (
  id SERIAL PRIMARY KEY NOT NULL,
  name VARCHAR(100) NOT NULL,
  age INT NOT NULL,
  certification certification NOT NULL,
  email VARCHAR(255) NOT NULL
);

/*
  Set of relations the express all necessary information
  related to DiveSite.
*/
CREATE Table DiveSite(
	id SERIAL PRIMARY KEY NOT NULL,
  name VARCHAR(255) NOT NULL,
  location VARCHAR(255) NOT NULL,
  diverFee INT NOT NULL, -- fee per diver
  maxCapacity INT NOT NULL
);

/*
	Table to represent monitor status for divers.
  Inclusion in this table means the diver with dID is a monitor
*/
CREATE Table Monitor(
  dID SERIAL PRIMARY KEY NOT NULL REFERENCES Diver,
  maxCapacity INT NOT NULL
);

/*
  The pricing for each Monitor depending on certain conditions.
	From handout, we know that the pricing depends time of day,
  divetype, divesite, and monitor.
*/
CREATE Table MonitorPricing(
  mID INT NOT NULL REFERENCES Monitor,
  diveTime diveTime NOT NULL,
  diveType diveType NOT NULL,
  diveSite INT NOT NULL REFERENCES DiveSite,
  pricing INT NOT NULL,
  PRIMARY KEY (mID, diveTime, diveType, diveSite)
);

/*
  The max number of diver a monitor can supervise during a dive of diveType.
	From handout, we know that capacity depends on the monitor and divetype
*/
CREATE Table MonitorCapacity(
  mID INT NOT NULL REFERENCES Monitor,
  diveType diveType NOT NULL,
  group_size INT NOT NULL,
  PRIMARY KEY (mID, diveType)
);

/*
  Monitor mID has booking privilege for divesite siteID.
*/
CREATE Table MonitorPrivilege(
  mID INT NOT NULL REFERENCES Monitor,
  siteID INT NOT NULL REFERENCES DiveSite,
  PRIMARY KEY (mID, siteID)
);

/*
  Represents if a divesite supports an optional service.
*/
CREATE Table DiveSiteService(
	sID INT NOT NULL REFERENCES DiveSite,
	service service NOT NULL,
  price INT NOT NULL,
  PRIMARY KEY (sID, service)
);

/*
  Represent if the divesite supports a diving type.
*/
CREATE Table DiveSiteDiveType(
	sID INT NOT NULL REFERENCES DiveSite,
	diveType diveType NOT NULL,
  -- piazza @689: the capacity is only dependent on diveType, not the dive time
  capacity INT,
  PRIMARY KEY (sID, diveType)
);

/*
  Represents the base Booking information. This is a pretty big table,
  but everything here only functionally depends on the booking id and
  does not have many duplicated, so we included a lot of information
  in this table.
*/
CREATE Table Booking(
  id SERIAL PRIMARY KEY NOT NULL,
   -- we're assuming there can only be one monitor
  monitorID INT NOT NULL REFERENCES Monitor,
  leadID INT NOT NULL REFERENCES Diver,
  siteID INT NOT NULL REFERENCES DiveSite,
  -- we won't store credit card info like this irl.
  creditCardInfo VARCHAR(100) NOT NULL,  
  -- info about the dive type and time/date
  diveTime diveTime NOT NULL,
  diveType diveType NOT NULL,
  bookingDate DATE NOT NULL,
	monitorRating INT
);

/*
  Represents if Booking bookingID has requested a certain optional
  service.
*/
CREATE Table BookingService(
    bookingID INT NOT NULL,
    service service NOT NULL,
    PRIMARY KEY (bookingID, service)
);

/* All the divers that are in a Dive */
CREATE Table BookingDiver(
  booking INT NOT NULL REFERENCES Booking,
  diver INT NOT NULL REFERENCES Diver,
  -- optional rating given by the diver. 
  -- Can be null. We didn't want to make a table just for this.
  rating INT
);
