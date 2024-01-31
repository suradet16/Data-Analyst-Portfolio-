select * from coviddeaths c 
order by 3,4


select * from covidvaccinations c2  
order by 3,4

select * from coviddeaths c 
where continent is notnull 
order by 3,4


--select location ,date, total_cases,new_cases, total_deaths, population
--from coviddeaths c 
--order by 1,2 

-- Looking at Total Cases vs Total Deaths

select location ,date, total_cases,total_deaths , (total_deaths :: float /total_cases :: float )*100 as DeathPercentage
from coviddeaths c 
order by 1,2 


-- Shows likelihood of dying if you contract covid in ur country

select location ,date, total_cases,total_deaths , (total_deaths :: float /total_cases :: float )*100 as DeathPercentage
from coviddeaths c 
where location like '%st%'
order by 1,2 


-- looking at total case vs population
-- show what percentage of population got Covid

select location ,population ,MAX(total_cases) as HighestINfectionCount , MAX(total_cases :: float /population :: float )*100 as PercentPopulationInfected
from coviddeaths c 
--where location like '%Arg%'
group by Location,population 
order by PercentPopulationInfected desc 




-- LET'S BREAK THINGS DOWN BY CONTINENT


SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    NULLIF(vac.new_vaccinations, '')::INTEGER AS new_vaccinations,
    SUM(NULLIF(vac.new_vaccinations, '')::INTEGER) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM
    coviddeaths  dea
JOIN
    covidvaccinations  vac ON dea.location = vac.location AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL
ORDER BY    2, 3;



-- Showing Countries with Highest Death Count per Population


select location  ,MAX(total_deaths) as TotalDeathCount 
from coviddeaths c 
where continent is not null 
group by location
order by TotalDeathCount desc 


-- GLOBAL NUMBERS

select  date, SUM(new_cases), SUM(new_deaths :: int) as total_deaths-- , --(total_deaths :: float /total_cases :: float )*100 as DeathPercentage
from coviddeaths c 
where continent is not null
group by date
order by 1,2 


-- looking at total Population vs Vacinations

-- USE CTE

with PopvsVAc (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated )
as
(
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    NULLIF(vac.new_vaccinations, '')::INTEGER AS new_vaccinations,
    SUM(NULLIF(vac.new_vaccinations, '')::INTEGER) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM
    coviddeaths  dea
JOIN
    covidvaccinations  vac ON dea.location = vac.location AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL
-- ORDER BY    2, 3;
   )
   select  * , (RollingPeopleVaccinated/population) * 100 from PopvsVAc


-- CREATE TEMPORARY TABLE
CREATE TEMPORARY TABLE PercentPopulationVaccinated
(
    continent VARCHAR(255),
    location VARCHAR(255),
    date timestamp,
    population numeric,
    new_vaccinations numeric,
    rollingpeoplevaccinated numeric
);

-- INSERT INTO TEMPORARY TABLE
INSERT INTO "PercentPopulationVaccinated"
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    NULLIF(CAST(vac.new_vaccinations AS NUMERIC), 0) AS new_vaccinations,
    SUM(NULLIF(CAST(vac.new_vaccinations AS NUMERIC), 0)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM
    coviddeaths dea
JOIN
    covidvaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL;

   
-- SELECT FROM TEMPORARY TABLE
SELECT *, (RollingPeopleVaccinated / population) * 100 AS PercentPopulationVaccinated
FROM PercentPopulationVaccinated;



CREATE View PercentPopulationVaccinated as
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    NULLIF(CAST(vac.new_vaccinations AS NUMERIC), 0) AS new_vaccinations,
    SUM(NULLIF(CAST(vac.new_vaccinations AS NUMERIC), 0)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM
    coviddeaths dea
JOIN
    covidvaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL;
   
   
  select * from PercentPopulationVaccinated 
