
SELECT *
  FROM [COVID-19_Data_Explorer].[dbo].[CovidDeaths]
  ORDER BY 3, 4

--SELECT *
--  FROM [COVID-19_Data_Explorer].[dbo].['CovidVaccinations']
--  ORDER BY 3, 4

SELECT location, date, total_cases, new_cases,population
  FROM [COVID-19_Data_Explorer].[dbo].[CovidDeaths]
  ORDER BY 1, 2

  -- Loking at Total Cases VS Total Death -------------------------------------------

  SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPersentage
  FROM [COVID-19_Data_Explorer].[dbo].[CovidDeaths]
  WHERE location like '%canada%'
  ORDER BY 1, 2

    -- Loking at Total Cases VS Population -------------------------------------------
	-- Show what percentage of population got Covid

  SELECT location, date, population, total_cases, (total_cases/population)*100 as PersentageOfCovid
  FROM [COVID-19_Data_Explorer].[dbo].[CovidDeaths]
  WHERE location like '%canada%'
  ORDER BY 1, 2 

  -- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From [COVID-19_Data_Explorer].[dbo].[CovidDeaths]
--Where location like '%canada%'
order by 1,2


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From [COVID-19_Data_Explorer].[dbo].[CovidDeaths]
--Where location like '%canada%'
Group by Location, Population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [COVID-19_Data_Explorer].[dbo].[CovidDeaths]
--Where location like '%canada%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [COVID-19_Data_Explorer].[dbo].[CovidDeaths]
--Where location like '%canada%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [COVID-19_Data_Explorer].[dbo].[CovidDeaths]
--Where location like '%canada%'
where continent is not null 
--Group By date
order by 1,2

--==================================================================================================================================================
-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
--==================================================================================================================================================

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM (CONVERT (int, v.new_vaccinations)) OVER (Partition by d.location ORDER BY d.location, d.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [dbo].[CovidDeaths] d
JOIN [dbo].[CovidVaccinations] v ON d.[location] = v.[location]
AND d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY 2,3

--==================================================================================================================================================
--** Using CTE to perform Calculation on Partition By in previous query
--==================================================================================================================================================

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM (CONVERT (int, v.new_vaccinations)) OVER (Partition by d.location ORDER BY d.location, d.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [dbo].[CovidDeaths] d
JOIN [dbo].[CovidVaccinations] v ON d.[location] = v.[location]
AND d.date = v.date
WHERE d.continent IS NOT NULL
--ORDER BY 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--==================================================================================================================================================
-- Using Temp Table to perform Calculation on Partition By in previous query
--==================================================================================================================================================

DROP TABLE IF exists #PercentPopulationVaccinated

CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM (CONVERT (int, v.new_vaccinations)) OVER (Partition by d.location ORDER BY d.location, d.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [dbo].[CovidDeaths] d
JOIN [dbo].[CovidVaccinations] v ON d.[location] = v.[location]
AND d.date = v.date
--WHERE d.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100 as Percentage
FROM #PercentPopulationVaccinated

--==================================================================================================================================================
-- Creating View to store data for later visualizations
--==================================================================================================================================================

CREATE VIEW  PercentPopulationVaccinated AS
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM (CONVERT (int, v.new_vaccinations)) OVER (Partition by d.location ORDER BY d.location, d.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [dbo].[CovidDeaths] d
JOIN [dbo].[CovidVaccinations] v ON d.[location] = v.[location]
AND d.date = v.date
WHERE d.continent IS NOT NULL
--ORDER BY 2,3