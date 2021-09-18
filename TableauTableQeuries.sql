-- These tables can either be copied into Excel for manual import into Tableau, or created as views in a SQL Server connected to Tableau.

-- 1. 

Create View TableauTable1 as
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidExploration..CovidDeaths
where continent is not null 
--Group By date
--order by 1,2

-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where location = 'World'
----Group By date
--order by 1,2


-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Create View TableauTable2 as
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From CovidExploration..CovidDeaths
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
--order by TotalDeathCount desc


-- 3.

Create View TableauTable3 as
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentInfected
From CovidExploration..CovidDeaths
Group by Location, Population
--order by PercentInfected desc


-- 4.

Create View TableauTable4 as
Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentInfected
From CovidExploration..CovidDeaths
Group by Location, Population, date
--order by PercentInfected desc