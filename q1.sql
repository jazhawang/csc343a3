/*
    For each dive category from open water, cave, or 
    beyond 30 meters, list the number of dive sites that
    provide that dive type and have at least one monitor
    with booking privileges with them who will supervise 
    groups for that type of dive. 
*/

DROP VIEW IF EXISTS q1 CASCADE;

CREATE VIEW q1 AS
SELECT dsDiveTypes.diveType as diveType, count(*) AS num FROM 
DiveSites 
    -- determine if monitor has the privilege to book at the divesite
    JOIN MonitorPrivilege ON (DiveSites.id=MonitorPrivilege.siteID) 
    -- determine if the monitor actually offers the diveType
    JOIN MonitorPricing ON (MonitorPricing.mID=MonitorPricing.mID) 
    -- make sure that the divetype is supported at the divesite
    JOIN dsDiveTypes ON (dsDiveTypes.sID=DiveSites.id) 
GROUP BY dsDiveTypes.diveType;
