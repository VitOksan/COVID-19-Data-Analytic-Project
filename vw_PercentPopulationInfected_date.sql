CREATE VIEW vw_PercentPopulationInfected_date AS

SELECT Location,date, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
FROM CovidDeaths
--Where location like '%canada%'
WHERE Location not in ('Low income', 'Lower middle income', 'High income') AND total_cases/population is not null
GROUP BY Location, Population, date 
--ORDER BY PercentPopulationInfected DESC

SELECT * FROM [COVID-19_Data_Explorer].[dbo].[vw_PercentPopulationInfected_date]