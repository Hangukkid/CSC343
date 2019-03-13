
SET search_path TO parlgov
drop table if exists q3 cascade;


create table q3(
countryName VARCHaR(100),
partyName VARCHaR(100),
partyFamily VARCHaR(100),
wonElections INT,
mostRecentlyWonElectionId INT,
mostRecentlyWonElectionYear INT
);



DROP VIEW IF EXISTS lost_elections CASCADE;
DROP VIEW IF EXISTS won_elections CASCADE;
DROP VIEW IF EXISTS winning_times CASCADE;
DROP VIEW IF EXISTS num_parties CASCADE;
DROP VIEW IF EXISTS avg_win_party CASCADE;
DROP VIEW IF EXISTS most_recent_win_election CASCADE;
DROP VIEW IF EXISTS more_than_avg CASCADE;


--1. find all the parties that have lost in the elections
CREATE VIEW lost_elections AS
SELECT election_result1.id as erid, election_result1.election_id as eid, election_result1.party_id as pid, election_result1.votes as votes
FROM election_result as election_result1, election_result as election_result2
WHERE (election_result1.election_id = election_result2.election_id AND election_result1.votes < election_result2.votes) OR election_result1 IS NULL;

--2. find all the parties that have won in the elections
CREATE VIEW won_elections AS
SELECT election_id as eid, party_id as pid
FROM election_result EXCEPT(
							SELECT eid, pid
							FROM lost_elections);

--3. From all the parties which have won, get the number of how many times they have won
CREATE VIEW winning_times AS 
SELECT pid, count(eid) as num_party_win
FROM won_elections
GROUP BY pid;

--4. get the number how many parties each country has 
CREATE VIEW num_parties AS
SELECT country.id as cid, count(party.id) as party_count
FROM country JOIN party ON country.id = party.country_id
GROUP BY country.id;

--5. get the avrage number of wining elections of parties of the country 
CREATE VIEW avg_win_party AS
SELECT cid, (sum(num_party_win) / party_count) as avg_num_wins
FROM winning_times JOIN party ON pid = party.id JOIN num_parties ON cid = party.country_id 
GROUP BY cid, party_count;

--6. most recent winning election by this party 
CREATE VIEW most_recent_win_election AS
SELECT pid, eid, e_date
FROM won_elections JOIN election ON eid = election.id
WHERE (pid, e_date) in 
	(SELECT pid, max(e_date)
	FROM won_elections JOIN election ON eid = election.id
	GROUP BY pid);


--7. find parties that have won more than 3 times the average number of winning elections of parties of the same country
CREATE VIEW more_than_avg AS
SELECT party.name as partyName, winning_times.pid, cid, num_party_win, avg_num_wins, country.name as countryName, family, eid as most_recent_win_id, EXTRACT(YEAR FROM e_date) as year
FROM winning_times JOIN party ON winning_times.pid = party.id JOIN avg_win_party ON country_id = cid JOIN country ON cid = country.id 
	LEFT JOIN party_family ON pid = party_family.party_id JOIN most_recent_win_election ON winning_times.pid = most_recent_win_election.pid
WHERE num_party_win > 3*avg_num_wins;


insert into q3
SELECT countryName, partyName, family as partyFamily, num_party_win as wonElections, most_recent_win_id  as mostRecentlyWonElectionId, year as mostRecentlyWonElectionYear
FROM more_than_avg
