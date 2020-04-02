
/*
    For each dive category from open water, cave, or 
    beyond 30 meters, list the number of dive sites that
    provide that dive type and have at least one monitor
    with booking privileges with them who will supervise 
    groups for that type of dive. 
*/

DROP VIEW IF EXISTS OpenDiveSites CASCADE;
CREATE VIEW OpenDiveSites AS
    SELECT id as sid, 'open' as diveType 
    FROM dsDiveTypes
    WHERE dsDiveTypes.open=1;

DROP VIEW IF EXISTS CaveDiveSites CASCADE;
CREATE VIEW OpenDiveSites AS
    SELECT id as sid, 'cave' as diveType 
    FROM dsDiveTypes
    WHERE dsDiveTypes.cave=1;

DROP VIEW IF EXISTS DeepDiveSites CASCADE;
CREATE VIEW OpenDiveSites AS
    SELECT id as sid, 'deep' as diveType 
    FROM dsDiveTypes
    WHERE dsDiveTypes.deep=1;


DROP VIEW IF EXISTS AllDiveSites CASCADE;
CREATE VIEW AllDiveSites AS 
    SELECT * 
    FROM CaveDiveSites UNION OpenDiveSites UNION DeepDiveSites;

SELECT diveType, count(*) as num FROM 
DiveSites 
    JOIN MonitorPrivilege ON (DiveSites.id=MonitorPrivilege.siteID)
    JOIN MonitorPricing ON (MonitorPricing.mID=MonitorPricing.mID)
    JOIN AllDiveSites ON (AllDiveSites.sid=DiveSites.id)
GROUP BY diveType
