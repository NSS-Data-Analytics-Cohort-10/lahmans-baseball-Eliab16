## Lahman Baseball Database Exercise
- this data has been made available [online](http://www.seanlahman.com/baseball-archive/statistics/) by Sean Lahman
- A data dictionary is included with the files for this project.

### Use SQL queries to find answers to the *Initial Questions*. If time permits, choose one (or more) of the *Open-Ended Questions*. Toward the end of the bootcamp, we will revisit this data if time allows to combine SQL, Excel Power Pivot, and/or Python to answer more of the *Open-Ended Questions*.



**Initial Questions**

---1. What range of years for baseball games played does the provided database cover? 
---ans
 
 SELECT MIN(year),
 MAX(year)
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
--ans Which Vanderbilt player earned the most money in the majors?

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
  ---  ans David Price
  
    

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
		   
    	   
     	   
ANS "Outfield"  29560
    "Battery"   41424
    "Infield"	58934  
		     
           
		   
  
-- 5. Find the average number of strikeouts per game by decade since 1920.
Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?
--ans   
  SELECT  (yearid/10)*10 AS decade,
   ROUND (AVG(SO/G),2) AS AVG_strikeouts_per_game
   FROM pitching
   where yearid >=1920
   GROUP BY decade
   ORDER BY AVG_strikeouts_per_game;
   
   
   or 
   
   
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
   
  --  ans  see query
  
  
   -- 6. Find the player who had the most success stealing bases in 2016,
where __success__ is measured as the percentage of stolen base attempts which are successful
. (A stolen base attempt results either in a stolen base or being caught stealing.) 
Consider only players who attempted _at least_ 20 stolen bases.

   SELECT namefirst,namelast,(sb*100/(sb+cs)) AS psb
   FROM batting b
   LEFT JOIN people p
   USING(playerid)
   WHERE (sb+cs)>=20 and yearid=2016
   GROUP BY namefirst,namelast,psb						  
   ORDER BY psb DESC;
  
  --ANS Chris Owings
   
7.  From 1970 – 2016, what is the largest number of wins for a team that did not win the world series?
What is the smallest number of wins for a team that did win the world series? 
Doing this will probably result in an unusually small number of wins for a world series champion – 
determine why this is the case. Then redo your query, excluding the problem year.
How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? 
What percentage of the time?
--- 1981 small number of wins 
---
SELECT YearID,Max(W) as maxw, 
 SUM (CASE WHEN wswin='Y' THEN 1 ELSE 0 END) AS total_wins
FROM Teams
WHERE yearID >=1970 AND  yearID !='1981'
GROUP BY YearID
ORDER BY maxw DESC;

--ans  116 most wins without winning the world series,74 least wins by world series.   
	 
   with cte AS (
	           SELECT yearid,max(w) AS maxw
	           FROM teams
	           WHERE yearid >=1970 AND yearID NOT IN (1981)
	           GROUP BY yearid
	           ORDER BY maxw DESC),
	   cte1 AS  (
	       Select teamid,yearid,w,wswin
	       FROM teams
	       WHERE yearid >=1970 AND yearID NOT IN (1981)
	       ORDER BY w DESC
	       )
   SELECT SUM(CASE WHEN wswin ='Y' THEN 1 ELSE 0 END) AS total_wins,
   COUNT(DISTINCT cte.yearid),
   ROUND(SUM(CASE WHEN wswin ='Y'THEN 1 ELSE 0 END)/COUNT(DISTINCT cte.yearid)::numeric,2)*100 as pt
   FROM cte1
   LEFT JOIN cte
   ON cte.yearid=cte1.yearid AND cte1.w=cte.maxw
   WHERE maxw IS NOT NULL;
   
   for percentage I got help from my group. 
   
   
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
		  
  WITH nl_winners AS(
	   SELECT DISTINCT
	         a.playerid AS nl_manager,
	         a.awardid,
	         a.lgid
	  FROM awardsmanagers a
	  WHERE a.awardid=  'TSN Manager of the Year' AND a.lgid='NL'
	   ), 
	 al_winners AS ( 
		 
	  SELECT DISTINCT
	         a.playerid AS al_manager,
	         a.awardid,
	         a.lgid
	  FROM awardsmanagers a
      WHERE a.awardid=  'TSN Manager of the Year' AND a.lgid='AL'
		)
	    SELECT DISTINCT  CONCAT (p.namefirst,'',p.namelast) as manager_full_name,
		a.yearid AS year_won,
		m.teamid AS team_won	     
		FROM awardsmanagers a
		INNER JOIN al_winners as al
	    ON a.playerid=al.al_manager
	    INNER JOIN nl_winners as nl
		ON a.playerid=nl.nl_manager
		INNER JOIN people p
		 USING(playerid) 	  
	    INNER JOIN managers m
		USING (playerid);
	    ON a.yearid=m.yearid
		
			  
--ans 		"DaveyJohnson"
             "JimLeyland"	  
			  
	
	           
--10. Find all players who hit their career highest number of home runs in 2016.    
--Consider only players who have played in the league for at least 10 years, 
--and who hit at least one home run in 2016. 
--Report the players' first and last names and the number of home runs they hit in 2016.
   
   

    
WITH career_hr AS(
		SELECT DISTINCT playerid, MAX(hr) AS max_hr 
	    FROM pitching 
		WHERE yearid =2016
       GROUP BY playerid
		--HAVING COUNT(DISTINCT yearid)>=10
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

 
 SELECT t.yearid,teamid,
 corr(t.w,s.salary) as correlation
 FROM teams as t
 JOIN (
  SELECT yearid,SUM(salary) AS salary
  FROM salaries
  WHERE yearid>=2000
 GROUP BY yearid
 ) as s
 ON t.teamid = s.teamid
 WHERE t.yearid>=2000
 GROUP BY t.yearid
 ORDER BY t.yearid;
-- not working-------
    SELECT corr(w,salary) AS correlation
	FROM(
	SELECT yearid,
		
		
 with team_data AS(
 SELECT
	 t.yearid,
	 t.w,
	 s.salary,
	 t.teamid,
 ROW_NUMBER()OVER(PARTITION BY t.yearid ORDER BY s.salary) as total_salary,
 ROW_NUMBER()OVER (PARTITION BY t.yearid ORDER BY t.w) as total_wins	
 FROM teams t
 INNER JOIN salaries s
 ON t.teamid=s.teamid AND t.yearid=s.yearid
 WHERE t.yearid >=2000
)
 SELECT 
  corr(total_salary,total_wins) as correlation
  FROM team_data ;
 --ans correlation coefficient=0.12		
 the value 0.12 indicate weak positive correlation between number of wins and total salary.	
		
		
		
		
12. In this question, you will explore the connection between number of wins and attendance.
    <ol type="a">
      <li>Does there appear to be any correlation between attendance at home games and number of wins? </li>
      <li>Do teams that win the world series see a boost in attendance the following year? 
		What about teams that made the playoffs? Making the playoffs means either being a division winner or a wild card winner.</li>
    </ol>

  select*from homegames;
  select*from teams;
  select*from AllstarFull;	
 with team_data AS(
    SELECT
	 t.yearid,
	 t.w,
	 h.attendance,
	 t.teamid,
 ROW_NUMBER()OVER(PARTITION BY t.yearid ORDER BY h.attendance) as total_attendance,
 ROW_NUMBER()OVER (PARTITION BY t.yearid ORDER BY t.w) as total_wins	
 FROM teams t
 INNER JOIN homegames h
 ON t.teamid=h.team AND t.yearid=h.year
 WHERE t.yearid >=2000
 )
  SELECT 
  corr(total_attendance,total_wins) as correlation
  FROM team_data;	

		correlation 0.46
		
13. It is thought that since left-handed pitchers are more rare,
		causing batters to face them less often, that they are more effective. 
		Investigate this claim and present evidence to either support or dispute this claim.
		First, determine just how rare left-handed pitchers are compared with right-handed pitchers.
		Are left-handed pitchers more likely to win the Cy Young Award? 
		Are they more likely to make it into the hall of fame?-- ans
	
		
	
		
	
		
		