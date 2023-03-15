/****** Script for SelectTopNRows command from SSMS  ******/
--SELECT TOP (1000) *
--  FROM [SQL Portfolio Projects].[dbo].[CovidDeaths]
--  order by 3,4

  /****** Script for SelectTopNRows command from SSMS  ******/
--SELECT TOP (1000) *
--  FROM [SQL Portfolio Projects].[dbo].[CovidVaccinations]
--  order by 3,4

-- Select Data for Usage of this project

select location, date, total_cases, new_cases, total_deaths, population
from coviddeaths
where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows Likelyhood of Death having COVID19

select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from coviddeaths
where location like '%states%' and continent is not null
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of the Population got COVID19

select location, date, population,  total_cases, (total_cases/population)*100 as PopulationPercentage
from coviddeaths
--where location like '%states%'
where continent is not null
order by 1,2


-- Looking at Countries with the highest Infection Rates compared to Population

select location, population,  max(total_cases) as HighestInfectionCount, max((total_cases/population)*100) as HighestPopulationRate
from coviddeaths
--where location like '%states%'
where continent is not null
group by location, population
order by HighestPopulationRate desc


-- Looking at Countries with Highest Deat Count per Population

select location, max(cast(total_deaths as int)) as HighestDeathCount
from coviddeaths
--where location like '%states%'
where continent is not null
group by location
order by HighestDeathCount desc


-- Looking at Continents with Highest Deat Count

select continent, max(cast(total_deaths as int)) as HighestDeathCount
from coviddeaths
--where location like '%states%'
where continent is not null
group by continent
order by HighestDeathCount desc


-- Global Numbers

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage 
from [SQL Portfolio Projects].dbo.CovidDeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2 desc


-- Look at Total Population that is Vaccinated

WITH PopVsVac (Continent, Location, Date, Population, NewVaccinations, RollingVaccinations)
as
(
Select a.continent, a.location, a.date, a.population, b.new_vaccinations,
sum(convert(int, b.new_vaccinations)) OVER (Partition by a.location Order by a.location, a.date) as RollingVaccinations
from [SQL Portfolio Projects].dbo.CovidDeaths a
inner join [SQL Portfolio Projects].dbo.CovidVaccinations b
	on a.location = b.location
	and a.date = b.date
where a.continent is not null
--order by 2,3
)
select *, (RollingVaccinations/Population)*100
from PopVsVac


-- Temp Table

DROP table if exists #PercentagePopVac

Create table #PercentagePopVac
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
NewVaccinations numeric,
RollingVaccinations numeric
)

Insert into #PercentagePopVac
Select a.continent, a.location, a.date, a.population, b.new_vaccinations,
sum(convert(int, b.new_vaccinations)) OVER (Partition by a.location Order by a.location, a.date) as RollingVaccinations
from [SQL Portfolio Projects].dbo.CovidDeaths a
inner join [SQL Portfolio Projects].dbo.CovidVaccinations b
	on a.location = b.location
	and a.date = b.date
where a.continent is not null
--order by 2,3

Select *, (RollingVaccinations/Population)*100 from #PercentagePopVac


-- Creating view for future visualizations

Create View PercentagePopVac as 
Select a.continent, a.location, a.date, a.population, b.new_vaccinations,
sum(convert(int, b.new_vaccinations)) OVER (Partition by a.location Order by a.location, a.date) as RollingVaccinations
from [SQL Portfolio Projects].dbo.CovidDeaths a
inner join [SQL Portfolio Projects].dbo.CovidVaccinations b
	on a.location = b.location
	and a.date = b.date
where a.continent is not null
--order by 2,3

select * from PercentagePopVac