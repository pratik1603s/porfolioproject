SELECT location,date,total_cases,new_cases,total_deaths,population
  FROM [portfolio project].[dbo].[CovidDeaths$]
  ORDER BY 1,2

--- Tot Deaths vs Tot Cases
--- SHOW likelihood of dying if contact with COVID in india
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS death_percentage
  FROM [portfolio project].[dbo].[CovidDeaths$]
  WHERE location = 'india'
  ORDER BY 1,2

---Tot cases vs Pop
---shows what % of Pop Gets COVID
SELECT location,date,population,total_cases,(total_cases/population)*100 AS Case_percentage
  FROM [portfolio project].[dbo].[CovidDeaths$]
  WHERE location = 'india'
  ORDER BY 1,2

---Looking at countries with highest Case rate compare with population
SELECT location,population,MAX(total_cases) AS HighestInfectionCount,
MAX((total_cases/population))*100 AS Case_percentage
  FROM [portfolio project].[dbo].[CovidDeaths$]
  GROUP BY location,population
  ORDER BY Case_percentage DESC

--- Countries with Highest death count per population
SELECT location,population,MAX (total_deaths ) AS MAX_Deaths 
FROM [portfolio project].[dbo].[CovidDeaths$]
Group by location,population
Order By Max_deaths DESC

--- In Column total_deaths is varchar convert into INT
SELECT location,population,MAX (CAST(total_deaths AS int) ) AS MAX_Deaths 
FROM [portfolio project].[dbo].[CovidDeaths$]
WHERE continent is not NULL ----- to exclude continent
Group by location,population
Order By Max_deaths DESC
 
 ---- SHOWING Max Deaths per Continent
SELECT location,MAX (CAST(total_deaths AS int) ) AS MAX_Deaths 
FROM [portfolio project].[dbo].[CovidDeaths$]
WHERE continent is NULL 
Group by location
Order By Max_deaths DESC
 -------------------------------------------------------------------------
 ---TOT pop VS TOT vaccinations
 SELECT D.continent,D.location,D.date,D.population,V.new_vaccinations, SUM (CAST(V.new_vaccinations AS int) )
 OVER ( Partition By D.location ORDER BY D.location,d.date) AS Rolling_Vaccinated_People
------- (Rolling_Vaccinated_People/population)*100  { Cant use Column Just Created, HENCE create CTE }
 FROM [portfolio project].[dbo].[CovidDeaths$] D
    join  [portfolio project].[dbo].[CovidVaccinations$] V
	On D.location=V.location
	AND D.date=V.date
	WHERE D.continent is not null
	ORDER BY 2,3

----USE CTE
--WITH column number must be matched with SELECT column number
WITH popvsvac (continent,location,date,population,new_vaccinations,Rolling_Vaccinated_People) AS
(SELECT D.continent,D.location,D.date,D.population,V.new_vaccinations, SUM (CAST(V.new_vaccinations AS int) )
 OVER ( Partition By D.location ORDER BY D.location,d.date) AS Rolling_Vaccinated_People
 FROM [portfolio project].[dbo].[CovidDeaths$] D
    join  [portfolio project].[dbo].[CovidVaccinations$] V
	On D.location=V.location
	AND D.date=V.date
	WHERE D.continent is not null
	----ORDER BY 2,3 
)
SELECT *, (Rolling_Vaccinated_People/population)*100
FROM popvsvac


------TEMP Table

CREATE TABLE PercentageofPeopleVaccinated
(continent nvarchar(255) ,
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Rolling_Vaccinated_People numeric)

INSERT INTO PercentageofPeopleVaccinated
SELECT D.continent,D.location,D.date,D.population,V.new_vaccinations, SUM (CAST(V.new_vaccinations AS int) )
 OVER ( Partition By D.location ORDER BY D.location,d.date) AS Rolling_Vaccinated_People
 FROM [portfolio project].[dbo].[CovidDeaths$] D
    join  [portfolio project].[dbo].[CovidVaccinations$] V
	On D.location=V.location
	AND D.date=V.date
	WHERE D.continent is not null
	----ORDER BY 2,3 
SELECT *, (Rolling_Vaccinated_People/population)*100
FROM PercentageofPeopleVaccinated
	

	
