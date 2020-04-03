/*  q1.sql

    For each dive category from open water, cave, or 
    beyond 30 meters, list the number of dive sites that
    provide that dive type and have at least one monitor
    with booking privileges with them who will supervise 
    groups for that type of dive. 
*/

DROP TABLE IF EXISTS q1 CASCADE;
CREATE TABLE q1 (
    diveType diveType NOT NULL,
    num INT -- number of valid divesites
);

/* The answer to q1. We find all divesites/divetype combos with a 
   valid monitor (qualified and is offering services).  */
INSERT INTO q1
SELECT DiveSiteDiveType.diveType as diveType, count(*) AS num 
FROM DiveSite 
    -- make sure that the divetype is supported at the divesite
    JOIN DiveSiteDiveType ON (DiveSiteDiveType.sID=DiveSite.id)
    -- make sure that there is a qualified monitor and is offering
    -- to monitor the divesite
WHERE EXISTS ( 
    SELECT *
    FROM MonitorPrivilege 
        JOIN MonitorPricing ON (
            MonitorPricing.mID=MonitorPrivilege.mID and
            MonitorPricing.divesite=MonitorPrivilege.siteID
            ) 
    WHERE MonitorPrivilege.siteID=DiveSite.id and 
          MonitorPricing.diveType=DiveSiteDiveType.diveType
)
GROUP BY DiveSiteDiveType.diveType;
