
SET search_path TO parlgov;
drop table if exists q2 cascade;

-- You must not change this table definition.

CREATE TABLE q2(
        countryName VARCHAR(50),
        partyName VARCHAR(100),
        partyFamily VARCHAR(50),
        stateMarket REAL
);

DROP VIEW IF EXISTS all_cabinet CASCADE;
DROP VIEW IF EXISTS num_cabinet CASCADE;
DROP VIEW IF EXISTS num_party CASCADE;
DROP VIEW IF EXISTS valid_party CASCADE;

-- 1. find all the cabinets in the past 20 years 
CREATE VIEW all_cabinet AS
SELECT id, country_id
FROM cabinet
WHERE EXTRACT(YEAR FROM start_date) > 1998 and EXTRACT(YEAR FROM start_date) <= 2019;

-- 2. get the number of cabinets in one country
CREATE VIEW num_cabinet AS
SELECT all_cabinet.country_id, country.name, count(all_cabinet.id) as num_c
FROM all_cabinet, country
WHERE all_cabinet.country_id = country.id
GROUP BY all_cabinet.country_id, country.name;

--3. count the number of cabinets that this party is in
CREATE VIEW num_party AS
SELECT cabinet_party.party_id, party_family.family, count(cabinet_id) as num_p
FROM cabinet_party, party_family, all_cabinet
WHERE cabinet_party.party_id = party_family.party_id AND all_cabinet.id = cabinet_party.cabinet_id
GROUP BY cabinet_party.party_id, party_family.family;

--4. select valid parties which has been a member of all cabinets in their country
CREATE VIEW  valid_party AS
SELECT party_id, family
FROM num_party
WHERE EXISTS (SELECT * 
				FROM  num_cabinet
				WHERE num_cabinet.num_c = num_party.num_p);


-- the answer to the query 
insert into q2
SELECT country.name as countryName, party.name as partyName, party_family.family as partyFamily,
	party_position.state_market as stateMarket
FROM valid_party, country, party, party_family, party_position
WHERE party.country_id = country.id AND 
		valid_party.party_id = party.id AND
		valid_party.party_id = party_family.party_id AND
		valid_party.party_id = party_position.party_id;


