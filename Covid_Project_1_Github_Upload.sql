/* Showcase of basic SQL profeicncy using healthcare data relating to the Covid-19 virus and pandemic. Data acquired from "https://ourworldindata.org/".

This project was initially completed via Google BigQuery, the syntax was copied to MySQL for eaiser exportation to Github. As a result, certain queries for things like table creation have been ommited due to BigQuery's automated functions */ 

-- Total Cases/ Population --
-- Shows what percentage of the countries population was afflicted--

SELECT 
  location, date, total_cases, population,(total_cases/population* 100) as InfectionRate
FROM `portfolio-projects-375517.Covid_Project_1.covid_deaths` as covid_deaths
ORDER BY 
  InfectionRate 


-- Which countries had the highest infection rate per capita? --

SELECT 
  location,population, MAX(total_cases) as HighestCaseCount, MAX (total_cases/population * 100) as Percent_Of_Population_Infected 
FROM `portfolio-projects-375517.Covid_Project_1.covid_deaths` as covid_deaths
GROUP BY
  location, population
ORDER BY
  Percent_Of_Population_Infected desc


-- Finding the leathality of Covid by country--

SELECT 
  location, date, total_cases, total_deaths,(total_deaths/total_cases *100) as DeathPercentage
FROM `portfolio-projects-375517.Covid_Project_1.covid_deaths` as covid_deaths
ORDER BY
  1,2;  


-- Which countries had the highest death toll? --

SELECT 
  location, MAX(total_deaths) as Death_Count, 
  -- Location can be substitued with other groupings within the data eg. Continent or GDP -- 
FROM `portfolio-projects-375517.Covid_Project_1.covid_deaths` as covid_deaths
WHERE
  continent is not null
-- This is to mitigate innate grouping issues within the data schemea when looking only at individual countries-- 
GROUP BY
  location
ORDER BY
  Death_count desc


-- Which continents had the highest death toll? --

SELECT 
  continent, MAX(total_deaths) as Death_Count, 
FROM `portfolio-projects-375517.Covid_Project_1.covid_deaths` as covid_deaths
WHERE
  continent is not null
 GROUP BY
  continent
ORDER BY
  Death_count desc
 
 
-- Joining the data from the two table -- 

SELECT  * 
FROM  `portfolio-projects-375517.Covid_Project_1.covid_deaths` as dea
  Join `portfolio-projects-375517.Covid_Project_1.covid_vaccinations` as vax
    On dea.location = vax.location and dea.date = vax.date
    

-- A more complex query to compare data between the newly joined tables -- 

SELECT  
  dea.continent,
  dea.location, 
  dea.date, 
  dea.population, 
  vax.new_vaccinations,
  SUM (vax.new_vaccinations) OVER (partition by dea.location 
    ORDER BY dea.location, dea.date) as RollingVax, 
  FROM  `portfolio-projects-375517.Covid_Project_1.covid_deaths` as dea
  Join `portfolio-projects-375517.Covid_Project_1.covid_vaccinations` as vax
    On dea.location = vax.location and dea.date = vax.dateWHERE
  dea.continent is not null
ORDER BY 
  2,3 


-- The following query is an example of a calcualtoin with the joined tables-- 
-- SQL won't allow a created column "RollingVax" to be used in a calculation within the same Select clause. As a work around, a CTE a.k.a temporary table was created using the full query-- 
WITH Pop_vs_Vax as 

(
  SELECT  
    dea.continent,
    dea.location, 
    dea.date, 
    dea.population, 
    vax.new_vaccinations,
    SUM (vax.new_vaccinations) OVER (partition by dea.location 
      ORDER BY dea.location, dea.date) as RollingVax, 
    

  FROM  `portfolio-projects-375517.Covid_Project_1.covid_deaths` as dea
    Join `portfolio-projects-375517.Covid_Project_1.covid_vaccinations` as vax
      On dea.location = vax.location and dea.date = vax.date
  WHERE
    dea.continent is not null

  ORDER BY 
    2,3 
)
-- Now "Rolling Vax" can be used in calculations --
SELECT 
  *, RollingVax/Population * 100
FROM Pop_vs_Vax

/* The results from said queries were downloaded directly from BigQuery and uploaded to Tableau for visualization*/