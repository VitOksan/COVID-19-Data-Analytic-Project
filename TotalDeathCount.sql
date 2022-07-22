
CREATE VIEW [dbo].[vw_TotalDeathCount] AS

SELECT location, SUM(CAST(new_deaths AS int)) AS TotalDeathCount
FROM [COVID-19_Data_Explorer]..CovidDeaths
--Where location like '%canada%'
WHERE continent is null 
and location not in ('World', 'European Union', 'International', 'Upper middle income', 'Lower middle income', 'High income') 
GROUP BY location

SELECT * FROM vw_TotalDeathCount

