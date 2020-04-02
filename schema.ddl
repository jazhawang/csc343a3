
/* Schema for CSC343 A3 */

drop schema if exists wetworldschema cascade;
create schema wetworldschema;
set search_path to wetworldschema;


/*
  Types for fixed domain specific information
*/
CREATE TYPE certification AS ENUM ('NAUI', 'CMAS', 'PADI');
CREATE TYPE diveType AS ENUM('open', 'cave', 'deep');
CREATE TYPE diveTime AS ENUM('morning', 'afternoon', 'night');
CREATE TYPE service AS ENUM('video', 'snacks', 'hot_showers', 'towel_service');


/*
  Contains the crucial information about each diver
*/
CREATE Table Diver (
  id SERIAL PRIMARY KEY NOT NULL,
  age INT NOT NULL,
  certification NOT NULL,
  email VARCHAR(255) NOT NULL
);

/*
	Table to represent monitor status for divers.
  Inclusion in this table means the diver with dID is a monitor
*/
CREATE Table Monitor(
  dID SERIAL PRIMARY KEY NOT NULL REFERENCES Diver
);

/*
  The pricing for each Monitor depending on certain conditions.
	From handout, we know that the pricing depends time of day, 
  divetype and monitor.
*/
CREATE Table MonitorPricing(
  mID INT NOT NULL REFERENCES Monitor,
  diveTime NOT NULL,
  diveType NOT NULL,
  diveSite INT NOT NULL REFERENCES DiveSites,
  pricing INT NOT NULL,
  PRIMARY KEY (mID, diveTime, diveType)
);

/*
  The max number of diver a monitor can supervise during a dive of diveType.
	From handout, we know that capacity depends on the monitor and divetype
*/
CREATE Table MonitorCapacity(
  mID INT NOT NULL REFERENCES Monitor,
  diveType NOT NULL,
  group_size INT NOT NULL,
  PRIMARY KEY (mID, diveType)
);

/* 
  Monitor mID has booking privilege for divesite siteID.
*/
CREATE Table MonitorPrivilege(
  mID INT NOT NULL REFERENCES Monitor,
  siteID INT NOT NULL REFERENCES DiveSites,
  PRIMARY KEY (mID, siteID)
);

/*
  Set of relations the express all necessary information
  related to divesites.
*/
CREATE Table DiveSites(
	id SERIAL PRIMARY KEY NOT NULL,
	sID INT NOT NULL, -- TODO: why do we have this?
	name VARCHAR(255) NOT NULL
);

/*
  Represents if a divesite supports an optional service.
*/
CREATE Table dsServices(
	sID INT NOT NULL REFERENCES DiveSites,
	service NOT NULL,
  price INT NOT NULL,
  PRIMARY KEY (sID, service)
);

/*
  Represent if the divesite supports a diving type.
*/
CREATE Table dsDiveTypes(
	sID INT NOT NULL REFERENCES DiveSites,
	diveType NOT NULL,
  -- piazza @689: the capacity is only dependent on diveType
  capacity INT NOT NULL,
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
  monitorRating INT,
  -- we won't store credit card info like this irl.
  creditCardInfo VARCHAR(100) NOT NULL,
  emailAddress VARCHAR(100) NOT NULL, -- TODO: do we need this? The leadID should be a diver with an email.
  -- info about the dive type and time/date
  diveTime NOT NULL,
  diveType NOT NULL,
  bookingDate DATE NOT NULL
);

/* 
  Represents if Booking bookingID has requested a certain optional 
  service.
*/
CREATE Table BookingService(
    bookingID INT NOT NULL,
    service NOT NULL,
    PRIMARY KEY (bookingID, service)
);

/* All the divers that are in a Dive */
CREATE Table BookingDiver(
  booking INT NOT NULL REFERENCES Booking,
  diver INT NOT NULL REFERENCES Diver,
  -- optional rating given by the diver. Can be null. We didn't want to make a table just for this.
  rating INT 
);
