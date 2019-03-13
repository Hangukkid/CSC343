SET search_path TO parlgov;
drop table if exists q1 cascade;


-- define table 
CREATE TABLE q1(
        countryId INT, 
        alliedPartyId1 INT, 
        alliedPartyId2 INT
);


DROP VIEW IF EXISTS pairAlliance CASCADE;
DROP VIEW IF EXISTS num_election CASCADE;

-- Define views 
-- 1. get all the pairs for alliance 
CREATE VIEW pairAlliance AS
SELECT election_result1.party_id as pid1, 
      election_result2.party_id as pid2, 
      election_result1.election_id,
      election.country_id
FROM election_result election_result1, election_result election_result2, election
WHERE election_result1.election_id = election_result2.election_id AND 
	(election_result1.id = election_result2.alliance_id OR election_result1.alliance_id = election_result2.alliance_id OR election_result1.alliance_id = election_result2.alliance_id) 
			AND election_result1.election_id = election.id
			AND election_result1.party_id < election_result2.party_id                                                                                                                                                                                                                                                     
GROUP BY(election_result1.election_id, election_result1.party_id, election_result2.party_id, election.country_id);

-- 2. get the total number of elections in each country 
CREATE VIEW num_election AS 
SELECT country_id, count(id) as election_count
FROM election
GROUP BY country_id;


--3. find the pairs in pairAlliance that have been allies with each other in at least 30% elections that happened in a country (num_election)

insert into q1 
SELECT pairAlliance.country_id as countryId,
		pairAlliance.pid1 as alliedPartyId1,
		pairAlliance.pid2 as alliedPartyId2
FROM pairAlliance, num_election
WHERE pairAlliance.country_id = num_election.country_id
GROUP BY  pairAlliance.country_id, pairAlliance.pid1, pairAlliance.pid2, num_election.election_count
HAVING count(*)/num_election.election_count::float >= 0.3;

--- HAVING COUNT(*) >= (sum_elections.election_cnt::numeric * 0.3);
