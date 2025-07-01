select *
from CovidDeaths
where continent is not null
order by 3,4

--select *
--from Covidvaccination
--order by 3,4

--select the data that we are going to be using

select location,date,total_cases ,new_cases ,total_deaths, population
from CovidDeaths
where continent is not null
order by 1, 2



--Looking at total cases vs Total Deaths
--show likelihood od dying if you contract covid in your country 
SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 AS death_rate
FROM CovidDeaths
where location like '%states%' and continent is not null
ORDER BY 1, 2;


SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 AS death_rate
FROM CovidDeaths
where location like '%states%' AND (total_deaths / total_cases)*100 is not null and continent is not null

ORDER BY 1, 2;

--looking at total_cases vs Population
--show what percentage of population got covid

select  location, date, total_cases ,population, (total_cases/population)*100 rate_cases
from CovidDeaths
where location like '%states' and (total_cases/population) is not null and  continent is not null

order by 1, 2


--looking country with highest infection rate compared to population
select  location,avg((total_cases/population)*100) AvgRate_cases
from CovidDeaths
where (total_cases/population) is not null and continent is not null
group by location
order by 2 desc


select location, population, max(total_cases) highestInfection , max((total_cases/population)*100) as PercentPopulationInfected
from CovidDeaths
where continent is not null
group by location, population
order by 4 desc

--looking country with highest death count per population


select location , max(cast(total_deaths as int)) highestDeaths
from CovidDeaths
where continent is not null
group by location
order by 2 desc

--LET's Break things down by continent 


-- showing the continent with the highest death count per population

select continent , max(cast(total_deaths as int)) highestDeaths
from CovidDeaths
where continent is not null
group by continent
order by 2 desc


--global numbers

select sum(new_cases), sum(new_deaths) , sum(new_deaths)/sum(new_cases)*100
from CovidDeaths
where continent is not null
--group by date 1
order by 1,2


SELECT 
    date, 
    SUM(new_cases) AS total_new_cases, 
    SUM(new_deaths) AS total_new_deaths, 
    CASE 
        WHEN SUM(new_cases) = 0 THEN NULL 
        ELSE (SUM(new_deaths) / SUM(new_cases)) * 100 
    END AS death_rate_percentage
FROM 
    CovidDeaths
WHERE 
    continent IS NOT NULL
GROUP BY 
    date
HAVING 
    SUM(new_cases) <> 0
ORDER BY 
    date;



alter table coviddeaths
alter column total_cases int


select sum(cast(Total_cases as float)),sum( cast(total_deaths as float)) --, sum(total_deaths)/sum(total_cases)*100
from CovidDeaths
where continent is not null 


--looking at total population vs vaccination 

select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
,sum(convert(float,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date)
from CovidVaccination vac
join CovidDeaths dea
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 1,2,3

--USE CTE

with PopvsVac (continent, location,date,population,new_vaccinations,rollingvaccinated)
as(

select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
,sum(convert(float,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date)
as rollingpeaplevaccinated--, (rollingpeaplevaccinated/dea.population)*100
from CovidVaccination vac
join CovidDeaths dea
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *, (rollingvaccinated/population)*100 
from PopvsVac



--TEMP TABLE


DROP TABLE IF EXISTS #PercentPopulationVaccinated;

CREATE TABLE #PercentPopulationVaccinated (
    continent NVARCHAR(255),
    Location NVARCHAR(255),
    Population NUMERIC,
    new_vaccination NUMERIC,
    RollingPeapleVaccinated NUMERIC
);

INSERT INTO #PercentPopulationVaccinated
SELECT 
    dea.continent,
    dea.location,
    dea.population,
    vac.new_vaccinations,
    SUM(CONVERT(FLOAT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeapleVaccinated
FROM 
    CovidVaccination vac
JOIN 
    CovidDeaths dea ON dea.location = vac.location AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL;

SELECT 
    *,
    (RollingPeapleVaccinated / population) * 100 AS PercentPopulationVaccinated
FROM 
    #PercentPopulationVaccinated;


--creating view to store data for later visualizations

create view PercentPopulationVaccinated as
select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
,sum(convert(float,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date)
as rollingpeaplevaccinated--, (rollingpeaplevaccinated/dea.population)*100
from CovidVaccination vac
join CovidDeaths dea
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3



select * from PercentPopulationVaccinated