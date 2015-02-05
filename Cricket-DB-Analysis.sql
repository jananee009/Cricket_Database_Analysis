# Note: All the statistics have been computed using the cricket database downloaded from cricinfo.com.
# This database contains data about cricket matches played until August 2011.

SELECT * FROM Grounds
SELECT * FROM innings
SELECT * FROM matches
SELECT * FROM PlayerBattingStats
SELECT * FROM playerbattingstyles
SELECT * FROM PlayerBowlingStats
SELECT * FROM PlayerFieldingStats
SELECT * FROM PlayerMatchInfos
SELECT * FROM PlayerRoles
SELECT * FROM Players
SELECT * FROM PlayerTeams
SELECT * FROM Teams

# Calculate player batting averages in ODIs. 
SELECT 
pbs.playerid AS PLAYER_ID, 
p.fullname AS PLAYER_NAME, 
COUNT(pbs.matchid) AS NUMBER_OF_MATCHES_PLAYED, 
SUM(pbs.runs_scored) AS TOTAL_RUNS_SCORED, 
SUM(pbs.runs_scored)/COUNT(pbs.matchid) AS BATTING_AVERAGE 
FROM PlayerBattingStats pbs
INNER JOIN matches m ON pbs.matchid = m.id 
INNER JOIN players p ON p.id = pbs.playerid
WHERE matchtype = 'ODI' AND pbs.`runs_scored` IS NOT NULL
GROUP BY  pbs.playerid
ORDER BY BATTING_AVERAGE DESC

# Calculate total number  of centuries scored by batsmen  in ODIs	 
SELECT 
pbs.playerid AS PLAYER_ID, 
p.fullname AS PLAYER_NAME, 
COUNT(pbs.runs_scored) AS NUMBER_OF_CENTURIES
FROM PlayerBattingStats pbs
INNER JOIN matches m ON pbs.matchid = m.id 
INNER JOIN players p ON p.id = pbs.playerid
WHERE m.matchtype = 'ODI'  AND pbs.runs_scored >= 100
GROUP BY  pbs.playerid 
ORDER BY NUMBER_OF_CENTURIES DESC

# Find the highest score made by each batsman in ODI.	 
SELECT 
pbs.playerid AS PLAYER_ID, 
p.fullname AS PLAYER_NAME, 
MAX(pbs.runs_scored) AS HIGHEST_RUNS
FROM PlayerBattingStats pbs
INNER JOIN matches m ON pbs.matchid = m.id 
INNER JOIN players p ON p.id = pbs.playerid
WHERE m.matchtype = 'ODI'  AND pbs.runs_scored >= 100
GROUP BY  pbs.playerid 
ORDER BY HIGHEST_RUNS DESC


# Calculate player bowling averages for each player in all ODIs he has bowled in. Bowling average = runs conceded / wickets taken.
SELECT 
pbs.playerid AS PLAYER_ID, 
p.fullname AS PLAYER_NAME, 
COUNT(pbs.matchid) AS NUMBER_OF_MATCHES_PLAYED,
SUM(pbs.runs_given) AS TOTAL_RUNS_CONCEDED, 
SUM(pbs.wickets_taken) AS TOTAL_WICKETS_TAKEN, 
IF(SUM(pbs.wickets_taken)=0,100000000,(SUM(pbs.runs_given) / SUM(pbs.wickets_taken))) AS BOWLING_AVERAGE 
FROM PlayerBowlingStats pbs
INNER JOIN matches m ON pbs.matchid = m.id 
INNER JOIN players p ON p.id = pbs.playerid
WHERE matchtype = 'ODI' AND pbs.overs_bowled IS NOT NULL
GROUP BY  pbs.playerid
ORDER BY BOWLING_AVERAGE ASC

# Find the total number of wickets taken by each bowler in all ODIs he has bowled in.  
SELECT 
pbs.playerid AS PLAYER_ID, 
p.fullname AS PLAYER_NAME, 
COUNT(pbs.matchid) AS NUMBER_OF_MATCHES_PLAYED,
SUM(pbs.wickets_taken) AS TOTAL_WICKETS_TAKEN
FROM PlayerBowlingStats pbs
INNER JOIN matches m ON pbs.matchid = m.id 
INNER JOIN players p ON p.id = pbs.playerid
WHERE matchtype = 'ODI' AND pbs.overs_bowled IS NOT NULL
GROUP BY  pbs.playerid
ORDER BY TOTAL_WICKETS_TAKEN DESC 

# Calculate total number of maiden overs bowled by a bowler in all ODIs he has bowled in.
SELECT 
pbs.playerid AS PLAYER_ID, 
p.fullname AS PLAYER_NAME, 
COUNT(pbs.matchid) AS NUMBER_OF_MATCHES_PLAYED,
ROUND(SUM(pbs.overs_bowled)) AS NUMBER_OF_OVERS_BOWLED,
SUM(pbs.maidens_bowled) AS NUMBER_OF_MAIDENS_BOWLED
FROM PlayerBowlingStats pbs
INNER JOIN matches m ON pbs.matchid = m.id 
INNER JOIN players p ON p.id = pbs.playerid
WHERE m.matchtype = 'ODI' AND pbs.overs_bowled IS NOT NULL
GROUP BY  pbs.playerid
ORDER BY NUMBER_OF_MAIDENS_BOWLED DESC

# Find the total number of no balls bowled by each bowler in all ODIs he has bowled in.  
SELECT 
pbs.playerid AS PLAYER_ID, 
p.fullname AS PLAYER_NAME, 
COUNT(pbs.matchid) AS NUMBER_OF_MATCHES_PLAYED,
SUM(pbs.noballs_bowled) AS TOTAL_NUMBER_OF_NO_BALLS
FROM PlayerBowlingStats pbs
INNER JOIN matches m ON pbs.matchid = m.id 
INNER JOIN players p ON p.id = pbs.playerid
WHERE matchtype = 'ODI' AND pbs.overs_bowled IS NOT NULL
GROUP BY  pbs.playerid
ORDER BY TOTAL_NUMBER_OF_NO_BALLS DESC 

# Find all the bowlers who took atleast 5 wickets in the ODIs they  bowled in.  
SELECT table1.PLAYER_NAME,table2.TOTAL_NUMBER_OF_MATCHES_BOWLED,table1.NUMBER_OF_MATCHES_WITH_5W_HAUL
FROM
(SELECT 
pbs.playerid AS PLAYER_ID, 
p.fullname AS PLAYER_NAME, 
COUNT(pbs.matchid) AS NUMBER_OF_MATCHES_WITH_5W_HAUL
FROM PlayerBowlingStats pbs
INNER JOIN matches m ON pbs.matchid = m.id 
INNER JOIN players p ON p.id = pbs.playerid
WHERE matchtype = 'ODI' AND pbs.wickets_taken >= 5
GROUP BY  pbs.playerid) table1
INNER JOIN
(SELECT 
pbs.playerid AS PLAYER_ID, 
p.fullname AS PLAYER_NAME,
COUNT(pbs.matchid) AS TOTAL_NUMBER_OF_MATCHES_BOWLED
FROM PlayerBowlingStats pbs
INNER JOIN matches m ON pbs.matchid = m.id 
INNER JOIN players p ON p.id = pbs.playerid
WHERE matchtype = 'ODI' AND pbs.overs_bowled IS NOT NULL
GROUP BY  pbs.playerid) table2
ON table1.PLAYER_ID = table2.PLAYER_ID
ORDER BY table1.NUMBER_OF_MATCHES_WITH_5W_HAUL DESC

# Find Tendulkar's batting average against Australia in all ODI matches that Glen McGrath bowled for Australia
SELECT table2.PLAYER_ID, 
COUNT(table1.MATCH_ID) AS NUMBER_OF_ODIs_PLAYED_AGAINST_AUS, 
SUM(table2.RUNS_SCORED) AS TOTAl_RUNS_SCORED, 
SUM(table2.RUNS_SCORED) / COUNT(table1.MATCH_ID) AS BATTING_AVG_AGAINST_AUS_WITH_MCGRATH
FROM 
(SELECT pbs.matchid AS MATCH_ID FROM playerbowlingstats pbs
INNER JOIN players p ON p.id = pbs.playerid
INNER JOIN matches m ON m.id = pbs.matchid
WHERE LOWER(p.cname) LIKE '%glenn mcgrath%' AND m.matchtype = 'ODI' AND pbs.overs_bowled IS NOT NULL) table1
INNER JOIN 
(SELECT p.id AS PLAYER_ID, pbs1.matchid AS MATCHID, pbs1.runs_scored AS RUNS_SCORED FROM PlayerBattingStats pbs1
INNER JOIN players p ON pbs1.playerid = p.id
WHERE LOWER(p.cname) LIKE '%sachin tendulkar%' AND pbs1.runs_scored IS NOT NULL
) table2
ON table1.MATCH_ID = table2.MATCHID
GROUP BY table2.PLAYER_ID


# Find Tendulkar's batting average against Australia in all ODI matches that Glenn McGrath DID NOT bowl for Australia
SELECT 
table1.PLAYER_ID, 
table1.PLAYER_NAME, 
COUNT(table1.MATCHID) AS NUMBER_OF_ODIs_PLAYED_AGAINST_AUS, 
SUM(table1.RUNS_SCORED) AS TOTAL_RUNS_SCORED, 
SUM(table1.RUNS_SCORED) / COUNT(table1.MATCHID)  AS BATTING_AVG FROM 
(SELECT p.id AS PLAYER_ID, p.cname AS PLAYER_NAME, pbs1.matchid AS MATCHID, pbs1.runs_scored AS RUNS_SCORED, m.team1id, m.team2id  FROM PlayerBattingStats pbs1
INNER JOIN players p ON pbs1.playerid = p.id
INNER JOIN matches m ON m.id = pbs1.matchid
WHERE LOWER(p.cname) LIKE '%sachin tendulkar%' AND pbs1.runs_scored IS NOT NULL AND m.matchtype = 'ODI'
AND ( (m.team1id = 1 and m.team2id = 6) OR (m.team1id = 6 and m.team2id = 1))
) table1
LEFT OUTER JOIN	
(SELECT pbs.matchid AS MATCH_ID FROM playerbowlingstats pbs
INNER JOIN players p ON p.id = pbs.playerid
INNER JOIN matches m ON m.id = pbs.matchid
WHERE LOWER(p.cname) LIKE '%glenn mcgrath%' AND m.matchtype = 'ODI' AND pbs.overs_bowled IS NOT NULL
) table2
ON table1.MATCHID = table2.MATCH_ID
WHERE table2.MATCH_ID IS NULL
GROUP BY table1.PLAYER_ID






