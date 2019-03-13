/*
Tables involved:
election (id, country_id, e_date, wikipedia, seats_total, electorate, votes_cast, votes_valid, description, previous_parliament_election_id, previous_ep_election_id, e_type)
election_result (id, election_id, party_id, alliance_id, seats, votes, description)
party (id, country_id, name_short, name, description)
country (id, name, abbreviation, oecd_accession_date)
*/
SET SEARCH_PATH TO parlgov;
drop table if exists q4 cascade;


CREATE TABLE q4 
(
    "year" INT,
    countryName VARCHAR (50),
    voteRange VARCHAR (10),
    partyName VARCHAR (100) 
);

DROP VIEW IF EXISTS electionVotes CASCADE;
DROP VIEW IF EXISTS votes1996And2016 CASCADE;
DROP VIEW IF EXISTS partyVoteRatio CASCADE;
/*
- Extracting just the year from the dates
- Renaming columns into appropriate names for final table
- I BELIEVE I excluded rows where countries did not have an election 
*/
CREATE VIEW electionVotes AS
SELECT e.e_date AS "year", c.name AS countryName, er.votes AS totalVotes, e.votes_valid AS partyVotes, p.name AS partyName
FROM election e, election_result er, party p, country c
WHERE   e.id = er.election_id AND    
        p.id = er.party_id AND
        e.country_id = c.id;



CREATE VIEW votes1996And2016 AS
SELECT "year", countryName, totalVotes, partyVotes, partyName
FROM electionVotes
WHERE "year" > 1996 AND "year" <= 2016;

    
/*
- Calculated average of votes for each party and valid votes of the election, then found the ratio between the two for later use
- Excluded rows where partyRatio is 0
*/
CREATE VIEW partyVoteRatio AS 
SELECT "year", countryName, CAST(AVG(er.votes) / AVG(e.votes_valid) AS FLOAT) AS partyRatio, partyName
FROM votes1996And2016
WHERE partyRatio > 0
GROUP BY partyName;


INSERT INTO q4 ("year", countryName, voteRange, partyName)
SELECT "year", countryName, 
        CASE 
            WHEN partyRatio > 0     AND partyRatio <= 0.05  THEN "(0-5]"
            WHEN partyRatio > 0.05  AND partyRatio <= 0.1   THEN "(5-10]"
            WHEN partyRatio > 0.1   AND partyRatio <= 0.2   THEN "(10-20]"
            WHEN partyRatio > 0.2   AND partyRatio <= 0.3   THEN "(20-30]"
            WHEN partyRatio > 0.3   AND partyRatio <= 0.4   THEN "(30-40]"
            WHEN partyRatio > 0.4   AND partyRatio <= 1.0   THEN "(40-100]"
        END AS voteRange, partyName
FROM votes1996And2016;
