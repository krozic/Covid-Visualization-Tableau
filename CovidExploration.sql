Select *
From CovidExploration..CovidDeaths
Order by 3,4

--Select *
--From CovidExploration..CovidVaccinations
--Order by 3,4

--Select Data that we are going to be using

Select Location, date, total_cases,new_cases,total_deaths,population
From CovidExploration..CovidDeaths
order by 1,2

-- What percentage of people who are tested positive die?

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidExploration..CovidDeaths
Where location like '%Canada%'
order by 1,2

-- It is worth keeping in mind that this percentage assumes everyone who has contracted the disease has received a positive test
-- Deaths are also cumulative, so changes in treatment procedure that may reduce death (or hospitalization volume changes) will not be reflected as this is an average.

Select Location, date,population, total_cases, (total_cases/population)*100 as ContractionPercentage
From CovidExploration..CovidDeaths
Where location like '%Canada%'
order by 1,2

-- In Canada, 4.1% of the population has contracted Covid as of 9-11-21.
-- In reality, some individuals will have received more than 1 positive test, causing this number to be slightly inflated.

Select Location, date,population, total_cases, (total_cases/population)*100 as ContractionPercentage
From CovidExploration..CovidDeaths
Where location like '%states%'
order by 1,2

-- In the US, 12.3% of the population has contracted Covid.
-- Which country has the highest ContractionPercentage?

Select location,population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as ContractionPercentage
From CovidExploration..CovidDeaths
-- Need to group by location and population since the data has been consolidated with Max()
Group by location, population
order by ContractionPercentage

-- In Seychelles, 20.8% of the population has contracted Covid.
-- How does ContractionPercentage compare with DeathPercentage?

Select location,population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as ContractionPercentage, Max(cast(total_deaths as int)) as TotalDeathCount, (Max((cast(total_deaths as int)))/Max(total_cases))*100 as DeathPercentage
-- total_deaths was data type 'nvarchar(255)' which caused incorrect values to be returned.
-- This is easily circumvented by changing data type to int with cast()
From CovidExploration..CovidDeaths
-- Need to group by location and population since we are consolidating the data with Max()
Group by location, population
order by DeathPercentage desc

-- All of these observations are not exclusive, as totals are already collected into full continents or other areas in the 'location' variable.
-- These can be removed by subsetting the 'continent' variable with the condition 'not null'.

Select location,population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as ContractionPercentage, Max(cast(total_deaths as int)) as TotalDeathCount, (Max((cast(total_deaths as int)))/Max(total_cases))*100 as DeathPercentage
From CovidExploration..CovidDeaths
Where continent is not null
Group by location, population
order by DeathPercentage desc

-- Some of these countries may have poor testing resources, which would inflate the DeathPercentage.
-- In addition, Vanuatu only has 1 death and 4 contractions, so the result is not a large enough sample to be accurate

-- How are the TotalDeathCount distributed by continent?

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount, (Max((cast(total_deaths as int)))/Max(total_cases))*100 as DeathPercentage
From CovidExploration..CovidDeaths
Group by continent
order by DeathPercentage desc

-- Although the 'continent' variable contains information which can be used to factor and summarize, it appears there is a discrepancy between them and the summation provided with the 'continent' labels in the 'location' variable which should be noted:

Select continent, location, Max(cast(total_deaths as int)) as TotalDeathCount
From CovidExploration..CovidDeaths
Group by continent, location
order by continent

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From CovidExploration..CovidDeaths
Group by continent
order by continent

-- Grouping instead by location where continent == NULL results in a higher death count:

Select location,population, Max(cast(total_deaths as int)) as TotalDeathCount, (Max((cast(total_deaths as int)))/Max(total_cases))*100 as DeathPercentage
From CovidExploration..CovidDeaths
Where continent is null
Group by location, population
order by DeathPercentage desc

-- We can group by 'date' and use the 'new_' variables to see how global numbers change over time
-- We will have to use aggregate functions to accomplish this

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From CovidExploration..CovidDeaths
where continent is not null
Group by date
order by 1,2

-- This shows new cases per day, which can be summarized with:

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From CovidExploration..CovidDeaths
where continent is not null
order by 1,2

-- Using the other table provided, we can create a table including both death and vaccination data to compare Populate with Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From CovidExploration..CovidDeaths dea
Join CovidExploration..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3	

-- Although total_vaccinations provides the total vaccinations, a rolling count can also be calculated for each new date.

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.Date) as RollingVaccinationSum
-- RollingVaccinationSum provides a value for every observation and is not an aggregate function
-- Summing over 'location' and ordering the summation over date creates a cumulative sum for each date within each country.
From CovidExploration..CovidDeaths dea
Join CovidExploration..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3	

-- It gets a bit messy if you want to use RollingVaccinationSum in future calculations
-- Here are a few ways to create some temporary tables to reference:

-- Using CTE

With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
-- Make sure the columns match what is being sourced
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.Date) as RollingVaccinationSum
From CovidExploration..CovidDeaths dea
Join CovidExploration..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)

-- Now we can Select from the table the same as the original table
-- Much less verbose.

Select *, (RollingVaccinationSum/Population)*100 as RollingPercentVaccinated
From PopVsVac

-- TEMP TABLE

-- First create the new table with the variables you require

Drop Table if exists #PercentVaccinated
-- If you plan to make alterations and run multiple times, this prevents having to add this later to avoid errors.
Create Table #PercentVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaccinationSum numeric
)

-- Now insert the data into the empty table

Insert into #PercentVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaccinationSum
From CovidExploration..CovidDeaths dea
Join CovidExploration..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *, (RollingVaccinationSum/Population)*100 as RollingPercentVaccinated
From #PercentVaccinated


-- Creating View for Tableau visualizations

Create View PercentVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaccinationSum
From CovidExploration..CovidDeaths dea
Join CovidExploration..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

