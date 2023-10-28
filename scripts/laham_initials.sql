## Lahman Baseball Database Exercise
- this data has been made available [online](http://www.seanlahman.com/baseball-archive/statistics/) by Sean Lahman
- A data dictionary is included with the files for this project.

### Use SQL queries to find answers to the *Initial Questions*. If time permits, choose one (or more) of the *Open-Ended Questions*. Toward the end of the bootcamp, we will revisit this data if time allows to combine SQL, Excel Power Pivot, and/or Python to answer more of the *Open-Ended Questions*.



**Initial Questions**

---1. What range of years for baseball games played does the provided database cover? 
---ans
 
 SELECT MIN(year),MAX(year)
 FROM homegames;

 ANS 1871-2016


--2. Find the name and height of the shortest player in the database.
How many games did he play in? What is the name of the team for which he played?
 --ans
 
 select*from appearances;
 
  SELECT namefirst,namelast,height
    FROM people as p
	WHERE height IS NOT NULL
	order by height ASC
	LIMIT 1;
 ---Eddie Gaedel ---height "43"
  
    SELECT namefirst,height,name,
	sum(G_all) as total_game
    FROM people
	INNER JOIN appearances
	USING(playerid)
	INNER JOIN teams
	USING (teamid)
	WHERE height IS NOT NULL 
	GROUP BY namefirst,height,G_all,name
	order by height ASC
	LIMIT 1;
   
 -- 52 games,St.Louis Browns
  
--3. Find all players in the database who played at Vanderbilt University. 
-- ans
 
 SELECT namefirst,namelast,namegiven,schoolname
 FROM schools
 JOIN collegeplaying
 USING(schoolid)
 JOIN people
 USING(playerid)
 WHERE schoolname='Vanderbilt University'
GROUP BY namefirst,namelast,namegiven,schoolname;	

---got 24 rows


--- Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues.
 
   
	 SELECT namefirst,namelast,schoolname,
	 sum(salary):: numeric:: money as total_salary
	 FROM schools
	INNER JOIN collegeplaying
	USING(schoolid)
	INNER JOIN Salaries
	USING (playerid)
	INNER JOIN people
	USING (playerid)
	where schoolname='Vanderbilt University'
	group by namefirst,namegiven,namelast,schoolname
	order by total_salary DESC;
	
-Sort this list in descending order by the total salary earned. 
---Which Vanderbilt player earned the most money in the majors?

  SELECT DISTINCT namefirst,namelast,schoolname,
	max(salary):: numeric:: money as max_salary
	 FROM schools
	INNER JOIN collegeplaying
	USING(schoolid)
	INNER JOIN Salaries
	USING (playerid)
	INNER JOIN people
	USING (playerid)
	where schoolname='Vanderbilt University'
	group by namefirst,namegiven,namelast, schoolname
	order by max_salary DESC;
  
  
    

-- 4. Using the fielding table, 
-- group players into three groups based on their position: 
-- label players with position OF as "Outfield", 
-- those with position "SS", "1B", "2B",and "3B" as "Infield", 
-- and those with position "P" or "C" as "Battery". 
-- Determine the number of putouts made by each of these three groups in 2016.

 --ans          
		 
		  
	  	  SELECT                                       
		  CASE
		    WHEN pos ='OF' THEN 'Outfield'
	    	WHEN pos IN ('SS','1B','2B','3B') THEN 'Infield'
            WHEN pos IN('P', 'C') THEN 'Battery'
			 END AS player_group,
			SUM(po) as total_po
		    FROM fielding
		   WHERE yearid = 2016
		   GROUP BY player_group
		   ORDER BY total_po;
           
		   
-- ans total 7rows
select*from pitching;
		   
-- 5. Find the average number of strikeouts per game by decade since 1920.
Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?
--ans   
  SELECT  (yearid/10)*10 AS decade,
   ROUND (AVG(SO/G),2) AS AVG_strikeouts_per_game
   FROM pitching
   where yearid >=1920
   GROUP BY decade
   ORDER BY AVG_strikeouts_per_game;
   
   
   
   
   
 WITH strikeouts_per_decade AS(
	  SELECT
	  (yearid/10)*10 AS decade,
	  count(G) AS total_games,
	  AVG(SO) AS average_strikeouts
	  FROM pitching
	  WHERE yearid >=1920
	  GROUP BY decade
 )
      SELECT decade,
	  ROUND(average_strikeouts/total_games,2) AS average_strikeout_per_game
      FROM strikeouts_per_decade
	  ORDER BY decade;
   
   
   
 --ans
   
   SELECT  (yearid/10)*10 AS decade,
   ROUND (AVG(HR/G),2) AS AVG_Homeruns_per_game
   FROM pitching
   where yearid >=1920
   GROUP BY decade
   ORDER BY AVG_Homeruns_per_game;
 
  
 
   

-- 6. Find the player who had the most success stealing bases in 2016,
where __success__ is measured as the percentage of stolen base attempts which are successful
. (A stolen base attempt results either in a stolen base or being caught stealing.) 
Consider only players who attempted _at least_ 20 stolen bases.

select*from Fieldingpost;
	

7.  From 1970 – 2016, what is the largest number of wins for a team that did not win the world series?
What is the smallest number of wins for a team that did win the world series? 
Doing this will probably result in an unusually small number of wins for a world series champion – 
determine why this is the case. Then redo your query, excluding the problem year.
How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? 
What percentage of the time?
--- 1981 small number of wins 
---
SELECT name,YearID,WSWin,SUM(W) as wins ,SUM(L) as losses
FROM Teams
WHERE yearID >=1970 AND  yearID !='1981'AND WSWin='Y' 
GROUP BY name,YearID,WSwin
ORDER BY wins DESC;

--

SELECT name,YearID,WSWin,SUM(W) as wins ,SUM(L) as losses
FROM Teams
WHERE yearID >=1970 AND  yearID !='1981'AND WSWin='N' 
GROUP BY name,YearID,WSwin
ORDER BY wins ASC;
   
--8. Using the attendance figures from the homegames table, 
find the teams and parks which had the top 5 average attendance per game in 2016 
(where average attendance is defined as total attendance divided by number of games). 
Only consider parks where there were at least 10 games played. Report the park name, 
team name, and average attendance. Repeat for the lowest 5 average attendance.


  SELECT park_name,team,year,
  sum(attendance)/sum(games) AS average_attendance
  FROM homegames
  INNER JOIN parks
  using(park)
  WHERE year='2016'  AND games>=10
  GROUP BY team,year,park_name
  ORDER BY average_attendance DESC
  LIMIT 5;
--   
  SELECT park_name,team,year,
  sum(attendance)/sum(games) AS average_attendance
  FROM homegames
  INNER JOIN parks
  using(park)
  WHERE year='2016'  AND games>=10
  GROUP BY team,year,park_name
  ORDER BY average_attendance ASC
  LIMIT 5;
 


--9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)?
Give their full name and 
the teams that they were managing when they won the award.
--ans
  SELECT DISTINCT p.namefirst,p.namelast,m.teamid
  FROM awardsmanagers a
  JOIN people p
  USING(playerid)
  JOIN managershalf m
  using(playerid)
  where a.awardid='TSN Manager of the Year' and a.lgid IN('NA','AL');
	

--10. Find all players who hit their career highest number of home runs in 2016.    
--Consider only players who have played in the league for at least 10 years, 
--and who hit at least one home run in 2016. 
--Report the players' first and last names and the number of home runs they hit in 2016.
   
   select*from salaries;

    WITH career_highest AS(
		SELECT DISTINCT playerid,MAX(hr) AS max_hr 
	    FROM pitching
        GROUP BY playerid
		),
	player_hr_2016 AS (
	    SELECT DISTINCT playerid,sum(hr) AS hr_2016
		FROM people
		WHERE yearid=2016
		GROUP BY playerid
		),
		Qualified_players AS(
		SELECT DISTINCT  c.playerid
	    FROM career_highest c
        INNER JOIN player_hr_2016 h
		ON c.playerid=h.playerid
		WHERE h.hr_2016>0
		HAVING COUNT(DISTINCT EXTRACT(YEAR FROM h.yearid))>=10
		)
		SELECT DISTINCT p.namefirst,p.namelast,c.high_HR_carrer,h.hr_2016
		FROM career_highest c
		INNER JOIN player_hr_2016 h
		ON c.playerid=h.playerid
		INNER JOIN people p
		ON c.playerid=p.playerid
		INNER JOIN Qualified_player
		ON c.playerid=e.playerid
		WHERE h.hr_2016=c.career_highest;
		
		
		
	---	 select*from salaries;

    
WITH career_hr AS(
		SELECT DISTINCT playerid,MAX(hr) AS max_hr 
	    FROM pitching 
		WHERE yearid<=2016
        GROUP BY playerid
		HAVING COUNT(DISTINCT yearid)>=10
	    ),
	player_hr_2016 AS (
	    SELECT DISTINCT playerid
		FROM pitchingpost
		WHERE yearid=2016 
		GROUP BY playerid
		HAVING SUM (HR)>=1
		)
	SELECT DISTINCT p.namefirst,p.namelast,
		pt.hr as career_high_hr
		FROM people p
		INNER JOIN career_hr chr
		ON p.playerid=chr.playerid
		INNER JOIN pitching pt
		ON p.playerid=pt.playerid
		INNER JOIN player_hr_2016 phr
		ON p.playerid=phr.playerid
		WHERE Pt.hr IS NOT NULL
		ORDER BY p.namelast,p.namefirst;
		
		

**Open-ended questions**

11. Is there any correlation between number of wins and team salary? 
Use data from 2000 and later to answer this question. 
As you do this analysis, keep in mind that salaries across the whole league tend to increase together, 
so you may want to look on a year-by-year basis.

 
 SELECT t.yearid,
 corr(t.w,s.total_salary) as correlation
 FROM teams as t
 JOIN (
  SELECT yearid,SUM(salary) AS total_salary
  FROM salaries
  WHERE yearid>=2000
 GROUP BY yearid
 ) as s
 ON t.yearid = s. yearid
 WHERE t.yearid>=2000
 GROUP BY t.yearid
 ORDER BY t.yearid;





12. In this question, you will explore the connection between number of wins and attendance.
    <ol type="a">
      <li>Does there appear to be any correlation between attendance at home games and number of wins? </li>
      <li>Do teams that win the world series see a boost in attendance the following year? What about teams that made the playoffs? Making the playoffs means either being a division winner or a wild card winner.</li>
    </ol>


13. It is thought that since left-handed pitchers are more rare, causing batters to face them less often, that they are more effective. Investigate this claim and present evidence to either support or dispute this claim. First, determine just how rare left-handed pitchers are compared with right-handed pitchers. Are left-handed pitchers more likely to win the Cy Young Award? Are they more likely to make it into the hall of fame?

  