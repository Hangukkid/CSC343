/*

Tables Involved: 
election (id, country_id, e_date, wikipedia, seats_total, electorate, votes_cast, votes_valid, description, previous_parliament_election_id, previous_ep_election_id, e_type)
country (id, name, abbreviation, oecd_accession_date)

*/


SET search_path TO parlgov;
drop table if exists q5 cascade;

CREATE TABLE q5 
(
    countryName          VARCHAR (50),
    "year"               INT,
    participationRatio   FLOAT
);



-- Getting country name, election date, election participation ratio 
CREATE VIEW countryElection AS
SELECT country.name AS countryName, YEAR(e_date) AS "year", CAST(votes_cast/electorate AS FLOAT) AS electionPartRatio
FROM election, country
WHERE election.country_id = country.id;


-- Filtering countries only between 2001 and 2016
CREATE VIEW countryRatio2001To2016 AS
SELECT countryName, "year", ROUND(AVG(electionPartRatio), 2) as participationRatio
FROM countryElection
WHERE "year" > 2001 AND "year" <= 2016
GROUP BY countryName, "year";


-- Finding all of the countries that do not have their ratios monotonically increasing between 2001 and 2016
-- Also do a chcek for if invalid countries is empty because there might be an error on their side that cannot fulfill a comparison with an empty table and result in nothing
CREATE VIEW invalidCountries AS
SELECT countryName
FROM countryRatio2001To2016 cr1
WHERE EXISTS
    (
        SELECT * 
        FROM countryRatio2001To2016 cr2
        WHERE   cr1."year" > c2."year" AND 
                cr1.participationRatio < cr2.participationRatio AND 
                cr1.countryName = cr2.countryName
    );


-- Removing those invalid countries from the original list
CREATE VIEW validCountries AS
SELECT * 
FROM countryRatio2001To2016 cr
WHERE NOT EXISTS 
(
    SELECT * 
    FROM invalidCountries ic
    WHERE cr.countryName = ic.countryName
);


INSERT INTO q5 (countryName, "year", participationRatio)
SELECT * FROM validCountries;




















