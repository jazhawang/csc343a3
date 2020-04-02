drop schema if exists wetworldschema cascade;
create schema wetworldschema;
set search_path to wetworldschema;

/*
	Declaring and expressing the constraints for which there are fixed values
*/
CREATE TYPE certification AS ENUM ('NAUI', 'CMAS', 'PADI');
CREATE TYPE diveType AS ENUM('open', 'cave', 'deep');
CREATE TYPE diveTime AS ENUM('morning', 'afternoon', 'night');
CREATE TYPE service AS ENUM('video', 'snacks', 'hot_showers', 'towel_service');


/*
Containing the crucial information about each diver
*/
CREATE Table Diver (
  id SERIAL PRIMARY KEY NOT NULL,
  age INT NOT NULL,
  certification NOT NULL,
  email VARCHAR(255) NOT NULL
);

/*
	Table to represent monitor status for divers
*/
CREATE Table Monitor(
  dID SERIAL PRIMARY KEY NOT NULL REFERENCES Diver
);

/*
	From handout, we know that Pricing depends time of day, divetype and monitor
*/
CREATE Table MonitorPricing(
  mID INT NOT NULL REFERENCES Monitor,
  diveTime NOT NULL,
  diveType NOT NULL,
  diveSite INT NOT NULL REFERENCES DiveSites,
  pricing INT NOT NULL
  PRIMARY KEY (mID, diveTime, diveType)
);

/*
	From handout, we know that Capacity depends on the monitor and divetype
*/
CREATE Table MonitorCapacity(
  mID INT NOT NULL REFERENCES Monitor,
  diveType NOT NULL,
  group_size INT NOT NULL,
  PRIMARY KEY (mID, diveType)
);

CREATE Table MonitorPrivilege(
  mID INT NOT NULL REFERENCES Monitor,
  siteID INT NOT NULL REFERENCES DiveSites,
  PRIMARY KEY (mID, siteID)
);


/*
Set of relaions the express all necessary information related to divesites
*/
CREATE Table DiveSites(
	id SERIAL PRIMARY KEY NOT NULL,
	sID INT NOT NULL,
	name VARCHAR(255) NOT NULL
);

/*
represents if a divesite supports an optional service
*/
CREATE Table dsServices(
	sID INT NOT NULL REFERENCES DiveSites,
	service NOT NULL,
    price INT NOT NULL,
    PRIMARY KEY (sID, service)
);

/*
represent if the divesite supports a diving type
*/
CREATE Table dsDiveTypes(
	sID INT NOT NULL REFERENCES DiveSites,
	diveType NOT NULL,
    capacity INT NOT NULL, /* piazza @689 */
    PRIMARY KEY (sID, diveType)
);

/*
TODO: How to deal with bookings. Do we need to include every single possible
diver that is on each of the bookings?
What does each booking tuple look like? Maybe start from there
*/
CREATE Table Booking(
  id SERIAL PRIMARY KEY NOT NULL,
  monitorID INT NOT NULL REFERENCES Monitor, -- I'm assuming that there can only be one monitor
  leadID INT NOT NULL REFERENCES Diver,
  siteID INT NOT NULL REFERENCES DiveSite,
  monitorRating INT
  creditCardInfo VARCHAR(100) NOT NULL,
  emailAddress VARCHAR(100) NOT NULL,
  diveTime NOT NULL,
  diveType NOT NULL,
  bookingDate DATE NOT NULL
);

CREATE Table BookingService(
    bookingID INT NOT NULL,
    service NOT NULL,
    PRIMARY KEY (bookingID, service)
);

/* All the divers that are in a Dive */
CREATE Table BookingDiver(
  booking INT NOT NULL REFERENCES Booking,
  diver INT NOT NULL REFERENCES Diver,
  rating INT
);
