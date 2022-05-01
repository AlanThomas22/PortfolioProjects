show databases;
use portfolioproject;
show tables;
select * 
from covidvaccinations;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM coviddeaths

-- shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, ( total_deaths/total_cases)*100 AS 'DeathPercentage'
FROM coviddeaths
WHERE location LIKE "%States%"
ORDER BY location ;

-- Looking at total cases vs population
-- shows what percentage of population got covid
SELECT location, date, population, total_cases, (total_cases/population) AS "CovidPercentage"
FROM coviddeaths
-- WHERE location LIKE "%States%"
ORDER BY location ;

--  countries with highest infection rate compared to population
SELECT location, population, max(total_cases) AS "HighestInfectionCount", max((total_cases/population))*100 AS "PercentPopulationAffected"
FROM coviddeaths
GROUP BY location, population
ORDER BY PercentPopulationAffected DESC;

-- showing countries with highest death count per population
SELECT location, max(total_deaths) AS "TotalDeathCount"
FROM coviddeaths
WHERE continent is NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- Let's break things down by continent
-- showing continents with highest death count per population
SELECT continent, max(total_deaths) AS "TotalDeathCount"
FROM coviddeaths
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- Global Numbers
SELECT date, sum(new_cases) AS "total_cases" ,sum(new_deaths) AS "total_deaths", (sum(new_deaths )/sum(new_cases))*100 as "DeathPercentage"
FROM coviddeaths
GROUP BY date;

SELECT*
FROM coviddeaths dea
JOIN covidvaccinations vac
ON dea.location= vac.location
AND
dea.date = vac.date;

-- Looking at total populations vs vaccinations
WITH PopVsVac (Continent, Location, date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) OVER (Partition By dea.location ORDER BY dea.location, dea.date) AS "RollingPeopleVaccinated"
FROM coviddeaths dea
JOIN covidvaccinations vac
ON dea.date = vac.date
AND
dea.location = vac.location
WHERE dea.continent IS NOT NULL
)
SELECT * ,(RollingPeopleVaccinated/population)*100
FROM PopVsVac;



-- Creating views to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) OVER (Partition By dea.location ORDER BY dea.location, dea.date) AS "RollingPeopleVaccinated"
FROM coviddeaths dea
JOIN covidvaccinations vac
ON dea.date = vac.date
AND
dea.location = vac.location
WHERE dea.continent IS NOT NULL;

SELECT *
FROM PercentPopulationVaccinated;



