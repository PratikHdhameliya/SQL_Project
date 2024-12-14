
-- Select all columns from CovidDeaths
SELECT * 
FROM SQLProject.CovidDeaths
ORDER BY 3,4;

-- Select specific columns from CovidDeaths
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM SQLProject.CovidDeaths
ORDER BY 1,2;

-- Total case vs total deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage 
FROM SQLProject.CovidDeaths
WHERE location LIKE '%state%'
ORDER BY 2;

-- Total cases vs population
SELECT location, date, population, total_cases, (total_cases/population)*100 AS CasePercentage 
FROM SQLProject.CovidDeaths
WHERE location LIKE 'India'
ORDER BY 5 DESC;

-- Country's with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS HigestInfectionCount, MAX((total_cases/population))*100 AS InfectionPercentage 
FROM SQLProject.CovidDeaths
WHERE location = 'India'
GROUP BY location, population
ORDER BY InfectionPercentage DESC;

-- Country's with highest death rate compared to population
SELECT location, date, population, MAX(total_deaths) AS HigestDeathCount, MAX((total_deaths/population))*100 AS DeathPercentage 
FROM SQLProject.Co
vidDeaths
GROUP BY location, population, date
ORDER BY population DESC;

-- Countries with highest death count per population
SELECT location, MAX(CAST(total_deaths AS SIGNED)) AS TotalDeathcount
FROM SQLProject.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathcount DESC;

-- By continent
SELECT continent, MAX(CAST(total_deaths AS SIGNED)) AS TotalDeathcount
FROM SQLProject.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathcount DESC;

-- Global group by date
SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS SIGNED)) AS total_deaths, SUM(CAST(new_deaths AS SIGNED))/SUM(new_cases)*100 AS DeathPercentage 
FROM SQLProject.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

-- Total global number
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS SIGNED)) AS total_deaths, SUM(CAST(new_deaths AS SIGNED))/SUM(new_cases)*100 AS DeathPercentage 
FROM SQLProject.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- Join CovidDeaths and CovidVaccinations
SELECT *
FROM SQLProject.CovidDeaths dea
JOIN SQLProject.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date;

-- Population vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM SQLProject.CovidDeaths dea
JOIN SQLProject.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
AND dea.location = 'India'
AND vac.new_vaccinations IS NOT NULL;

-- Max vaccination number with date in India
SELECT dea.location, dea.date, dea.population, vac.new_vaccinations
FROM SQLProject.CovidDeaths dea
JOIN SQLProject.CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
    AND dea.location = 'India'
    AND vac.new_vaccinations = (
        SELECT MAX(new_vaccinations)
        FROM SQLProject.CovidVaccinations
        WHERE location = 'India'
    );

-- Rolling people vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM SQLProject.CovidDeaths dea
JOIN SQLProject.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
ORDER BY 2,3;

-- Common table expression (CTE) for RollingPeopleVaccinated
WITH VaccinationData AS (
    SELECT 
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        ROW_NUMBER() OVER (PARTITION BY dea.location, dea.date ORDER BY dea.date) AS RowNum
    FROM 
        SQLProject.CovidDeaths dea
    JOIN 
        SQLProject.CovidVaccinations vac ON dea.location = vac.location
                                           AND dea.date = vac.date
    WHERE  
        dea.continent IS NOT NULL
)
SELECT 
    continent,
    location,
    date,
    population,
    new_vaccinations,
    SUM(CAST(new_vaccinations AS SIGNED)) OVER (PARTITION BY location ORDER BY date ROWS UNBOUNDED PRECEDING) AS RollingPeopleVaccinated
FROM 
    VaccinationData
WHERE 
    RowNum = 1
ORDER BY 
    location, date;

-- Using CTE to calculate percentage population vaccinated
WITH PopvsVac AS (
    SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
    SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
    FROM SQLProject.CovidDeaths dea
    JOIN SQLProject.CovidVaccinations vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS PercentPopulationVaccinated
FROM PopvsVac;

-- Using Temp Table to calculate percentage population vaccinated
DROP TEMPORARY TABLE IF EXISTS PercentPopulationVaccinated;
CREATE TEMPORARY TABLE PercentPopulationVaccinated (
    Continent VARCHAR(255),
    Location VARCHAR(255),
    Date DATETIME,
    Population DECIMAL(20,3),
    New_vaccinations DECIMAL(20,3),
    RollingPeopleVaccinated DECIMAL(20,3)
);

INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM SQLProject.CovidDeaths dea
JOIN SQLProject.CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date;

SELECT *, (RollingPeopleVaccinated/Population)*100 AS PercentPopulationVaccinated
FROM PercentPopulationVaccinated;
