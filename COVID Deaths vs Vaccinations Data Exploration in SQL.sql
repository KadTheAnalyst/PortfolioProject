SELECT *
FROM ProjectPortfolio..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4

--SELECT *
--FROM ProjectPortfolio..CovidVaccinations
--ORDER BY 3, 4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM ProjectPortfolio..CovidDeaths
ORDER BY 1, 2

--LOOKING AT TOTAL CASES VS TOTAL DEATHS
--Shows likelihood of dying if you contact covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM ProjectPortfolio..CovidDeaths
WHERE location LIKE '%india%' 
ORDER BY 1, 2

--LOOKING AT TOTAL CASES VS POPULATION
--Shows what percentage of population contracted covid
SELECT location, date, total_cases, population, (total_cases/population)*100 as CasesPercentage
FROM ProjectPortfolio..CovidDeaths
WHERE location LIKE '%india%' 
ORDER BY 1, 2

--COUNTRIS WITH HIGHEST INFECTION RATES COMPARED TO POPULATION
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as CasesPercentage
FROM ProjectPortfolio..CovidDeaths
--WHERE location LIKE '%india%' 
GROUP BY population, location
ORDER BY 4  DESC

--COUNTRIES  WITH HIGHEST DEATH COUNT PER POPULATION
SELECT location, MAX(total_deaths) as HighestDEATHCount
FROM ProjectPortfolio..CovidDeaths
WHERE continent IS NOT NULL
--WHERE location LIKE '%india%' 
GROUP BY location
ORDER BY 2  DESC

--BREAKDOWN BY CONTINENT
--SHOWING CONTINENTS WITH HIGHEST DEATH COUNTS PER POPULATION
SELECT continent, MAX(total_deaths) as HighestDEATHCount
FROM ProjectPortfolio..CovidDeaths
WHERE continent IS NOT NULL
--WHERE location LIKE '%india%' 
GROUP BY continent
ORDER BY 2  DESC

--GLOBAL NUMBERS
SELECT date SUM(NEW_cases) AS TOTAL_CASES, SUM(NEW_DEATHS) AS TOTAL_DEATHS,
(SUM(new_deaths))/(SUM(new_cases))*100 as DEATHPercentage
FROM ProjectPortfolio..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY datE
ORDER BY 1, 2

SELECT SUM(NEW_cases) AS TOTAL_CASES, SUM(NEW_DEATHS) AS TOTAL_DEATHS,
(SUM(new_deaths))/(SUM(new_cases))*100 as DEATHPercentage
FROM ProjectPortfolio..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1, 2

--LOOKING AT  TOTAL POPULATION VS VACCINATIONS
SELECT DEA.continent, DEA.location, DEA.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location order by dea.location, dea.Date) as CumulativePeopleVaccinated
FROM ProjectPortfolio..CovidDeaths dea
JOIN ProjectPortfolio..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
where DEA.continent is not null
order by 2, 3

--USE CTE

With PopvsVac (Continent, location, date, population, new_vaccinations, cumulativepeoplevaccinated)
as
(
SELECT DEA.continent, DEA.location, DEA.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location order by dea.location, dea.Date) as CumulativePeopleVaccinated
FROM ProjectPortfolio..CovidDeaths dea
JOIN ProjectPortfolio..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
where DEA.continent is not null
--order by 2, 3
)
SELECT *, (cumulativepeoplevaccinated/population)*100 AS PERCENTAGEVACCINATED
FROM PopvsVac

--TEMP TABLE
DROP TABLE IF EXISTS #PERCENTPOPULATIONVACCINATED
CREATE TABLE #PERCENTPOPULATIONVACCINATED
(
Continent nvarchar (255),
Location nvarchar (255),
date datetime,
Population numeric,
New_Vaccinations numeric,
CumulativePeopleVaccinated numeric
)

INSERT INTO #PERCENTPOPULATIONVACCINATED
SELECT DEA.continent, DEA.location, DEA.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location order by dea.location, dea.Date) as CumulativePeopleVaccinated
FROM ProjectPortfolio..CovidDeaths dea
JOIN ProjectPortfolio..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
where DEA.continent is not null
--order by 2, 3

--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATION
Create View PERCENTPOPULATIONVACCINATED as
SELECT DEA.continent, DEA.location, DEA.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location order by dea.location, dea.Date) as CumulativePeopleVaccinated
FROM ProjectPortfolio..CovidDeaths dea
JOIN ProjectPortfolio..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
where DEA.continent is not null
--order by 2, 3

select *
from PERCENTPOPULATIONVACCINATED
