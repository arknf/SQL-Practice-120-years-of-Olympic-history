-- How many olympics games have been held?
SELECT COUNT(DISTINCT Games) 
FROM athlete_events;

-- List down al Olympics games held so far
SELECT DISTINCT Year, Season, City
FROM athlete_events
ORDER BY Year;

-- Mention the total number of nations who participated in each olympics game
SELECT Year, Season, COUNT(DISTINCT NOC)
FROM athlete_events
GROUP BY Year;

--  highest and lowest no of countries participating in olympics
SELECT MIN(COUNT_NOC) as 'MINIMUM COUNTRES', MAX(COUNT_NOC)  as 'MAXIMUM COUNTRES'
FROM (
	SELECT Year, Season, COUNT(DISTINCT NOC) as COUNT_NOC
	FROM athlete_events
	GROUP BY Year
) tbl1;

-- Which nation has participated in all of the olympic games
with total_games as 
(
	SELECT COUNT(DISTINCT Games) as games_count
    FROM athlete_events
),
	countries as
(
    SELECT ae.Games, nr.region as nations
    FROM athlete_events as ae
    INNER JOIN noc_regions as nr
    ON ae.NOC = nr.NOC
    GROUP BY Games, region
),
	countries_participated as
(
	SELECT nations, COUNT(Games) as games_participated
    FROM countries
    GROUP BY nations
)

SELECT cp.*
FROM countries_participated as cp
INNER JOIN total_games as tg
ON tg.games_count = cp.games_participated;

-- Identify the sport which was played in all summer olympics
SELECT DISTINCT Sport
FROM athlete_events
WHERE Season = 'Summer';

-- Which sports were just played only once in the olympics
with unique_games as
(
	SELECT DISTINCT Games, Sport
    FROM athlete_events
),
	game_count as 
(
	SELECT Sport, COUNT(Games) as number_games
    FROM unique_games
    GROUP BY Sport
)
select game_count.*, unique_games.games
FROM game_count
INNER JOIN unique_games 
on unique_games.sport = unique_games.sport
WHERE game_count.number_games = 1
ORDER BY unique_games.sport;

-- Fetch the total number of sports played in each olympics games
with unique_games as 
(
	SELECT DISTINCT Games, Sport
    FROM athlete_events
),
	count_sports as
(
	SELECT Games, COUNT(Sport) as sports_count
    FROM unique_games
    GROUP BY Games
)
SELECT * from count_sports
ORDER BY sports_count DESC;

-- Fetch oldest athletes to win a gold medal
SELECT temporary.*, RANK() OVER(ORDER BY temporary.Age DESC) as ranking
FROM (
	SELECT Name, Sex, Age, Team, Games, City, Sport, Event, Medal
    FROM athlete_events
    WHERE Age != 'NA'
) as temporary
WHERE Medal = 'Gold'
ORDER BY ranking;

-- Find the ratio of male and female athletes participated in all olympic games
with male as
(
	SELECT COUNT(Sex) as m
    FROM athlete_events
    WHERE Sex = 'M'
),
	female as
(
	SELECT COUNT(Sex) as f
    FROM athlete_events
    WHERE Sex = 'F'
)
SELECT female.f/female.f, male.m/female.f
FROM male, female;

-- Fetch the top 5 athletes who have won the most gold medals
SELECT Name, count(medal) as total_medals
FROM athlete_events
WHERE Medal = 'Gold'
GROUP BY Name
ORDER BY total_medals DESC LIMIT 5;

-- Fetch the top 5 athletes who have won the most medals (gold/silver/bronze)
SELECT Name, count(medal) as total_medals
FROM athlete_events
WHERE Medal IN ('Gold','Silver','Bronze')
GROUP BY Name
ORDER BY total_medals DESC LIMIT 5;

-- Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won
SELECT nr.region, COUNT(Medal) as total_medal
FROM athlete_events as ae
JOIN noc_regions as nr
ON ae.NOC = nr.NOC
WHERE Medal in ('Gold','Silver','Bronze')
GROUP BY nr.region
ORDER BY total_medal DESC LIMIT 5;

SET SQL_SAFE_UPDATES = 0;
UPDATE athlete_events
SET Medal = 0
WHERE Medal = 'NA';

-- List down total gold, silver and bronze medals won by each country
SELECT 
    nr.region,
    COUNT( CASE WHEN Medal = 'Gold' THEN 1 END) as gold_medal,
    COUNT( CASE WHEN Medal = 'Silver' THEN 1 END) as silver_medal,
    COUNT( CASE WHEN Medal = 'Bronze' THEN 1 END) as bronze_medal
FROM athlete_events as ae
JOIN noc_regions as nr
ON ae.NOC = nr.NOC
GROUP BY region
ORDER BY gold_medal DESC, silver_medal DESC, bronze_medal DESC;

-- List down total gold, silver and bronze medal won by each country corresponding to each olympic games
SELECT 
	ae.Games,
    nr.region,
    COUNT( CASE WHEN Medal = 'Gold' THEN 1 END) as gold_medal,
    COUNT( CASE WHEN Medal = 'Silver' THEN 1 END) as silver_medal,
    COUNT( CASE WHEN Medal = 'Bronze' THEN 1 END) as bronze_medal
FROM athlete_events as ae
JOIN noc_regions as nr
ON ae.NOC = nr.NOC
GROUP BY Games, region
ORDER BY Games;

-- Identify which country won the most gold most silver and most bronze medal in each olympic games
with tb1 as
(
	SELECT Games, NOC as country_with_max_gold, MAX(max_gold) as max_gold
	FROM (
		SELECT
			DISTINCT Games,
			NOC,
			COUNT(Medal) as max_gold
		FROM athlete_events
		WHERE Medal = 'Gold'
		GROUP BY Games, NOC
		ORDER BY Games, max_gold DESC
	) as gold
	GROUP BY Games
	ORDER BY Games
),
	tb2 as
(
	SELECT Games, NOC as country_with_max_silver, MAX(max_silver) as max_silver
	FROM (
		SELECT
			DISTINCT Games,
			NOC,
			COUNT(Medal) as max_silver
		FROM athlete_events
		WHERE Medal = 'Silver'
		GROUP BY Games, NOC
		ORDER BY Games, max_silver DESC
	) as silver
	GROUP BY Games
	ORDER BY Games
),
	tb3 as
(
	SELECT Games, NOC as country_with_max_bronze, MAX(max_bronze) as max_bronze
	FROM (
		SELECT
			DISTINCT Games,
			NOC,
			COUNT(Medal) as max_bronze
		FROM athlete_events
		WHERE Medal = 'Bronze'
		GROUP BY Games, NOC
		ORDER BY Games, max_bronze DESC
	) as bronze
	GROUP BY Games
	ORDER BY Games
)
SELECT 
	tb1.Games, 
    tb1.country_with_max_gold, 
    tb2.country_with_max_silver,
    tb3.country_with_max_bronze
FROM tb1
JOIN tb2
ON tb1.Games = tb2.Games
JOIN tb3
ON tb2.Games = tb3.Games;

-- Identify which country won the most gold, most silver, most bronze medals and the most medals in each olympic games
with tb1 as
(
	SELECT Games, NOC as country_with_max_gold, MAX(max_gold) as max_gold
	FROM (
		SELECT
			DISTINCT Games,
			NOC,
			COUNT(Medal) as max_gold
		FROM athlete_events
		WHERE Medal = 'Gold'
		GROUP BY Games, NOC
		ORDER BY Games, max_gold DESC
	) as gold
	GROUP BY Games
	ORDER BY Games
),
	tb2 as
(
	SELECT Games, NOC as country_with_max_silver, MAX(max_silver) as max_silver
	FROM (
		SELECT
			DISTINCT Games,
			NOC,
			COUNT(Medal) as max_silver
		FROM athlete_events
		WHERE Medal = 'Silver'
		GROUP BY Games, NOC
		ORDER BY Games, max_silver DESC
	) as silver
	GROUP BY Games
	ORDER BY Games
),
	tb3 as
(
	SELECT Games, NOC as country_with_max_bronze, MAX(max_bronze) as max_bronze
	FROM (
		SELECT
			DISTINCT Games,
			NOC,
			COUNT(Medal) as max_bronze
		FROM athlete_events
		WHERE Medal = 'Bronze'
		GROUP BY Games, NOC
		ORDER BY Games, max_bronze DESC
	) as bronze
	GROUP BY Games
	ORDER BY Games
),
	tb4 as
(
	SELECT Games, NOC as country_with_max_medal, MAX(max_medal) as max_medal
	FROM (
		SELECT
			DISTINCT Games,
			NOC,
			COUNT(Medal) as max_medal
		FROM athlete_events
		WHERE Medal IN ('Gold','Silver','Bronze')
		GROUP BY Games, NOC
		ORDER BY Games, max_medal DESC
	) as medal
	GROUP BY Games
	ORDER BY Games
)
SELECT 
	tb1.Games, 
    tb1.country_with_max_gold, 
    tb2.country_with_max_silver,
    tb3.country_with_max_bronze,
    tb4.country_with_max_medal
FROM tb1
JOIN tb2
ON tb1.Games = tb2.Games
JOIN tb3
ON tb2.Games = tb3.Games
JOIN tb4
ON tb3.Games = tb4.Games;

-- Which countries have never won gold medal but have won silver/bronze medals
SELECT *
FROM (
	SELECT 
		nr.region,
		COUNT( CASE WHEN Medal = 'Gold' THEN 1 END) as gold_medal,
		COUNT( CASE WHEN Medal = 'Silver' THEN 1 END) as silver_medal,
		COUNT( CASE WHEN Medal = 'Bronze' THEN 1 END) as bronze_medal
	FROM athlete_events as ae
	JOIN noc_regions as nr
	ON ae.NOC = nr.NOC
	GROUP BY region
    ORDER BY region
) as tb1
WHERE gold_medal = 0 OR silver_medal = 0;

-- In which sport/event, india has won highest medals
SELECT Sport, COUNT(Medal) as total_medal
FROM athlete_events
WHERE Team = 'India'
GROUP BY Sport
ORDER BY total_medal DESC LIMIT 1;

-- Break down all olumpic games where India won medal for Hockey and how many medals in each olympic games
SELECT Team, Sport, Games, COUNT(Medal) as total_medals
FROM athlete_events
WHERE Team = 'India' AND Sport = 'Hockey' AND Medal != '0'
GROUP BY Games
ORDER BY total_medals DESC;