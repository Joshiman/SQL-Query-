
Select *
From PortfolioProjects..CovidDeath
where continent is not null
Order by 3,4

--Select *
--From PortfolioProjects..CovidDeath
--Order by 3,4
Select  Location , Date , total_cases , new_cases , total_deaths, population
From PortfolioProjects..CovidDeath
Order by 1,2

-- How many effected ppl will die from the death , Total case vs Total Death
Select  Location , Date , Population, Total_Cases , ISNULL(total_deaths,0) AS Total_Deaths,  (ISNULL(total_deaths,0)/total_cases)*100 as Death_Percentage
From PortfolioProjects..CovidDeath
where location like '%Eritrea%' or  location like '%Ethio%'
Order by 1,2


-- The highest Covid affected country  compared with poplations

Select  location ,  population,  MAX(Total_Cases) AS HigestInfectedCountry ,  Max((total_cases/population))*100 as HigestPercentageInfectedCountry
--ISNULL(total_deaths,0) AS Total_Deaths,  (ISNULL(total_deaths,0)/total_cases)*100 as Death_Percentage
From PortfolioProjects..CovidDeath
Group by location , population 
Order by 4 desc


----Total Highest Death by country per population 

Select  Location,  MAX(cast(Total_deaths as int)) AS TotalDeathCount
From PortfolioProjects..CovidDeath
where continent is not null
Group by location 
order by TotalDeathCount desc 


---Total death count by Continent 

Select  continent,  MAX(cast(Total_deaths as int)) AS TotalDeathCount
--(TotalDeathCount/population) as TotalPercetageDeath 
From PortfolioProjects..CovidDeath
where continent is not null
Group by continent 
order by TotalDeathCount desc 

---
-- - by Continent  
Select  location ,  MAX(cast(Total_deaths as int)) AS TotalDeathCount
From PortfolioProjects..CovidDeath
where continent is  null
Group by location, continent 
order by TotalDeathCount desc 


Select  continent ,  MAX(cast(Total_deaths as int)) AS TotalDeathCount
From PortfolioProjects..CovidDeath
where continent is not null
Group by  continent 
order by TotalDeathCount desc 


------------ Worldwide Death percentage by Day 
Select  Date ,  SUM(ISNULL(new_cases,0)) as  TotalCasePerDay , SUM(cast(ISNULL(new_deaths,0) as float)) as TotalDeathPerDay, SUM(cast(ISNULL(new_deaths,0) as int))/SUM(new_cases)*100 as DeathPercentage
--Total_cases , ISNULL(total_deaths,0) AS Total_Deaths,  (ISNULL(total_deaths,0)/total_cases)*100 as Death_Percentage
From PortfolioProjects..CovidDeath
where continent is not null 
group by Date
Order by 1,2 

--- Global Death percentage 
Select   SUM(ISNULL(new_cases,0)) as  TotalCasePerDay , SUM(cast(ISNULL(new_deaths,0) as float)) as TotalDeathPerDay, SUM(cast(ISNULL(new_deaths,0) as int))/SUM(new_cases)*100 as DeathPercentage
--Total_cases , ISNULL(total_deaths,0) AS Total_Deaths,  (ISNULL(total_deaths,0)/total_cases)*100 as Death_Percentage
From PortfolioProjects..CovidDeath
where continent is not null 
--group by Date
Order by 1,2 



-------------------------------------------  LET US DEAL WITH VACCINATION -----------------------------------

SELECT * 
FROM PortfolioProjects..CovidVaccinations vac
JOIN PortfolioProjects..CovidDeath  dea
on  dea.location = vac.location  
and dea.date = vac.date
--ALTER TABLE CovidVaccinations
--DROP COLUMN F10, F11, F12, F13, F14, F15, F16, F17, F18, F19, F20, F21, F22, F23, F24, F25,F26
ORDER BY 3,4 

----------LOOKING FOR TOTAL POPULATION VS VACCINATION 
-- USE  CTE

with PopvsVac ( Continent , Location , Date, Population, New_vaccinations, RollingVaccinatedPeople) 
as 
(

SELECT  dea.continent , dea.location , dea.date, dea.population , ISNULL(vac.new_vaccinations, 0), SUM(CAST(ISNULL(vac.new_vaccinations,0) as int)) OVER (partition by dea.location  Order by dea.date) AS RollingVaccinatedPeople
FROM PortfolioProjects..CovidVaccinations vac
JOIN PortfolioProjects..CovidDeath  dea 
on  dea.location = vac.location  
and dea.date = vac.date
where dea.continent is not null 
--ORDER BY 2,3
)
------------- HOW MANY PERCENTAGE OF THE POPULATION VACCINATED ? --------
 ---USE CTE
SELECT * ,  (RollingVaccinatedPeople/Population)*100 AS VaccinatedPerPopulation 
FROM PopvsVac

---MAKE A TEMPORARY TABLE 

DROP TABLE #PercentPopulationVaccianted 
CREATE TABLE #PercentPopulationVaccianted 
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination  numeric,
RollingVaccinatedPeople  numeric
)

INSERT INTO #PercentPopulationVaccianted 
SELECT  dea.continent , dea.location , dea.date, dea.population , ISNULL(vac.new_vaccinations, 0), SUM(CAST(ISNULL(vac.new_vaccinations,0) as int)) OVER (partition by dea.location  Order by dea.date) AS RollingVaccinatedPeople
FROM PortfolioProjects..CovidVaccinations vac
JOIN PortfolioProjects..CovidDeath  dea 
on  dea.location = vac.location  
and dea.date = vac.date
where dea.continent is not null 
--ORDER BY 2,3

SELECT * ,  (RollingVaccinatedPeople/Population)*100 AS VaccinatedPerPopulation 
FROM #PercentPopulationVaccianted 


--- CREATING VIEW  TO VISUALIZATIONS

CREATE VIEW  PercentPopulationVaccianted AS 
SELECT  dea.continent, dea.location , dea.date, dea.Population , ISNULL(vac.new_vaccinations, 0) as New_Vaccination, SUM(CAST(ISNULL(vac.new_vaccinations,0) as int)) OVER (partition by dea.location  Order by dea.date) AS RollingVaccinatedPeople
FROM PortfolioProjects..CovidVaccinations vac
JOIN PortfolioProjects..CovidDeath  dea 
     on  dea.location = vac.location  
     and dea.date = vac.date
where dea.continent is not null 
--ORDER BY 2,3



CREATE VIEW DeathByContinent AS
Select  continent,  MAX(cast(Total_deaths as int)) AS TotalDeathCount 
From PortfolioProjects..CovidDeath
where continent is not null
Group by continent 
--order by TotalDeathCount desc 



SELECT *
FROM PercentPopulationVaccianted
