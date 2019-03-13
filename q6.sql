/*
Tables involved: 
country (id, name, abbreviation, oecd_accession_date)
party (id, country_id, name_short, name, description)
party_position (party_id, left_right, state_market, liberty_authority)
*/
SET search_path TO parlgov;
drop table if exists q6 cascade;


CREATE TABLE q6 (
    countryName VARCHAR(50),
    "r0-2"  INT,
    "r2-4"  INT,
    "r4-6"  INT,
    "r6-8"  INT,
    "r8-10" INT
);

DROP VIEW IF EXISTS partyPositions CASCADE;
DROP VIEW IF EXISTS countryWithParties CASCADE;
DROP VIEW IF EXISTS party0To2 CASCADE;
DROP VIEW IF EXISTS party2To4 CASCADE;
DROP VIEW IF EXISTS party2To4 CASCADE;
DROP VIEW IF EXISTS party4To6 CASCADE;
DROP VIEW IF EXISTS party6To8 CASCADE;
DROP VIEW IF EXISTS party8To10 CASCADE;





CREATE VIEW partyPositions AS
SELECT country_id, left_right
FROM party, party_position
WHERE party.id = party_id;


CREATE VIEW countryWithParties AS
SELECT name as countryName, left_right
FROM country, partyPositions
WHERE country.id = country_id;


CREATE VIEW party0To2 AS
SELECT countryName, count(left_right) as "r0-2"
FROM countryWithParties
WHERE (left_right >= 0 AND left_right < 2) OR left_right is NULL
GROUP BY countryName;


CREATE VIEW party2To4 AS
SELECT countryName, count(left_right) as "r2-4"
FROM countryWithParties
WHERE (left_right >= 2 AND left_right < 4)
GROUP BY countryName;

CREATE VIEW party4To6 AS
SELECT countryName, count(left_right) as "r4-6"
FROM countryWithParties
WHERE (left_right >= 4 AND left_right < 6)
GROUP BY countryName;


CREATE VIEW party6To8 AS
SELECT countryName, count(left_right) as "r6-8"
FROM countryWithParties
WHERE (left_right >= 6 AND left_right < 8)
GROUP BY countryName;


CREATE VIEW party8To10 AS
SELECT countryName, count(left_right) as "r8-10"
FROM countryWithParties
WHERE (left_right >= 8 AND left_right <= 10)
GROUP BY countryName ;


INSERT INTO q6 (countryName, "r0-2", "r2-4", "r4-6", "r6-8", "r8-10")
SELECT *
FROM q6 FULL JOIN party0To2 ON q6."r0-2" = party0To2."r0-2";
 

INSERT INTO q6 (countryName, "r0-2", "r2-4", "r4-6", "r6-8", "r8-10")
SELECT *
FROM q6 FULL JOIN party0To2 ON q6."r2-4" = party0To2."r2-4";
 

INSERT INTO q6 (countryName, "r0-2", "r2-4", "r4-6", "r6-8", "r8-10")
SELECT *
FROM q6 FULL JOIN party0To2 ON q6."r4-6" = party0To2."r4-6";
 

INSERT INTO q6 (countryName, "r0-2", "r2-4", "r4-6", "r6-8", "r8-10")
SELECT *
FROM q6 FULL JOIN party0To2 ON q6."r6-8" = party0To2."r6-8";

INSERT INTO q6 (countryName, "r0-2", "r2-4", "r4-6", "r6-8", "r8-10")
SELECT *
FROM q6 FULL JOIN party0To2 ON q6."r8-10" = party0To2."r8-10";
 

