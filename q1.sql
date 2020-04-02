/*
    For each dive category from open water, cave, or 
    beyond 30 meters, list the number of dive sites that
    provide that dive type and have at least one monitor
    with booking privileges with them who will supervise 
    groups for that type of dive. 
*/

DROP VIEW IF EXISTS q1 CASCADE;

CREATE VIEW q1 AS
SELECT dsDiveTypes.diveType as diveType, count(*) AS num 
FROM DiveSites 
    -- make sure that the divetype is supported at the divesite
    JOIN dsDiveTypes ON (dsDiveTypes.sID=DiveSites.id)
WHERE EXISTS ( -- make sure that there is a qualified monitor and is offering
    SELECT *
    FROM MonitorPrivilege 
        JOIN MonitorPricing ON (
            MonitorPricing.mID=MonitorPrivilege.mID and
            MonitorPricing.divesite=MonitorPrivilege.siteID
            )
    WHERE MonitorPrivilege.siteID=DiveSites.id and 
          MonitorPricing.diveType=dsDiveTypes.diveType
)
GROUP BY dsDiveTypes.diveType;
