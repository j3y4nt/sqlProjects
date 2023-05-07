--Displaying the entire data
SELECT * FROM ResumeProject..covidDeaths
WHERE continent is not null
ORDER BY 3,4

-- REPLACING 0s with Null to enable mathematical operations
--UPDATE ResumeProject..covidDeaths
--SET total_deaths = 0
--WHERE total_deaths = Null

-- REPLACING 0s with Null to enable mathematical operations
--UPDATE ResumeProject..covidDeaths
--SET total_cases = 0
--WHERE total_cases = Null

-- CASTING the total_cases & total_deaths to INT for operations
--ALTER TABLE ResumeProject..covidDeaths ADD totalCases INT;
--UPDATE ResumeProject..covidDeaths SET totalCases = CAST(total_cases AS INT)
--ALTER TABLE ResumeProject..covidDeaths DROP COLUMN total_cases

--ALTER TABLE ResumeProject..covidDeaths ADD totalDeaths INT;
--UPDATE ResumeProject..covidDeaths SET totalDeaths = CAST(total_deaths AS INT)
--ALTER TABLE ResumeProject..covidDeaths DROP COLUMN total_cases


-- Looking at Deaths vs Cases
-- Shows % of total deaths out of total number of cases
SELECT location, date, totalDeaths, totalCases, (totalDeaths/totalCases)*100 as deathPercentage
FROM ResumeProject..covidDeaths
WHERE continent is not null
ORDER BY 1,2


-- Looking at Cases vs Population
-- Shows what % of population got affected by to Covid
SELECT location, date, totalCases, (totalCases/population)*100 as deathPercentage
FROM ResumeProject..covidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Looking at Total Deaths vs Population
-- Shows what % of population died due to Covid
SELECT location, date, totalDeaths, (totalDeaths/population)*100 as deathPercentage
FROM ResumeProject..covidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Looking at COUNTRIES with Highest Infection Rate compared to population
SELECT location, population, MAX(totalCases) as highestInfectionCount, MAX((totalCases/population))*100 as percentPopulationInfected
FROM ResumeProject..covidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY percentPopulationInfected desc

-- Looking at CONTINENTS with Death Count
SELECT continent, MAX(totalDeaths) as totalDeathCount
FROM ResumeProject..covidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY totalDeathCount desc



-- Replacing 0's with Null to enable operations
--UPDATE ResumeProject..covidDeaths
--SET new_cases = Null
--WHERE new_cases = 0

-- Daily Cases & Daily Deaths
SELECT date, SUM(new_cases) as dailyCases, SUM(new_deaths) as dailyDeaths, (SUM(new_deaths)/SUM(new_cases))*100 as deathPercent-- (totalDeaths/totalCases)*100 as deathPercentage
FROM ResumeProject..covidDeaths
WHERE continent is not null  
GROUP BY date
ORDER BY 1,2


-- Total Daily Cases & Total Daily Deaths
SELECT SUM(new_cases) as dailyCases, SUM(new_deaths) as dailyDeaths, (SUM(new_deaths)/SUM(new_cases))*100 as deathPercent-- (totalDeaths/totalCases)*100 as deathPercentage
FROM ResumeProject..covidDeaths
WHERE continent is not null  
--GROUP BY date
ORDER BY 1,2


-- Looking at Total Population vs Vaccinations USING CTE 

With popVsVac (Continent, Location, Date, Population, new_vaccinations, rollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(ISNULL(vac.new_vaccinations,0) AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rollingPeopleVaccinated
FROM ResumeProject..covidDeaths dea
JOIN ResumeProject..covidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (rollingPeopleVaccinated/Population)*100 
FROM popVsVac

-- USING TEMP TABLE

-- Use the DROP function to edit any metric and Create a new table again
-- DROP TABLE IF EXISTS #percentPopulationVaccinated
CREATE TABLE #percentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
Population numeric,
new_vaccinations numeric,
rollingPeopleVaccinated numeric
)


INSERT INTO #percentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(ISNULL(vac.new_vaccinations,0) AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rollingPeopleVaccinated
FROM ResumeProject..covidDeaths dea
JOIN ResumeProject..covidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (rollingPeopleVaccinated/Population)*100 
FROM #percentPopulationVaccinated

-- CREATING View to store data

CREATE VIEW percentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(ISNULL(vac.new_vaccinations,0) AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rollingPeopleVaccinated
FROM ResumeProject..covidDeaths dea
JOIN ResumeProject..covidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null

SELECT * FROM percentPopulationVaccinated