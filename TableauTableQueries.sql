-- These tables can either be copied into Excel for manual import into Tableau, or created as views in a SQL Server connected to Tableau.

-- 1. 

CREATE View TableauTable1 AS
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(New_Cases)*100 AS DeathPercentage
FROM CovidExploration..CovidDeaths
WHERE continent IS NOT NULL 

-- 2. 

CREATE View TableauTable2 AS
SELECT location, SUM(CAST(new_deaths AS INT)) AS TotalDeathCount
FROM CovidExploration..CovidDeaths
WHERE continent IS NULL
AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location

-- 3.

CREATE View TableauTable3 AS
SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount,  MAX((total_cases/population))*100 AS PercentInfected
FROM CovidExploration..CovidDeaths
GROUP BY Location, Population

-- 4.

CREATE View TableauTable4 AS
SELECT Location, Population,date, MAX(total_cases) AS HighestInfectionCount,  MAX((total_cases/population))*100 AS PercentInfected
FROM CovidExploration..CovidDeaths
GROUP BY Location, Population, date