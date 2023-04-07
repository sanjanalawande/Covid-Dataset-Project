
--Checking The Covid Deaths Table

select *
from CovidDeaths$
order by 3,4 ;

--Checking the Covid Vaccinations Table

select *
from Covidvaccinations
order by 3,4 ;


--Data Filtering

Select Location, date, total_cases , new_cases , total_deaths , population
from CovidDeaths$
order by 1,2 ;


-- Comparing Total Cases vs Total Deaths

Select Location, date, total_cases , total_deaths , (total_deaths/total_cases)*100 as PercentageDead
from CovidDeaths$
order by 1,2 ;


-- Comparing the death percentage for a specific location
-- Shows the probability of dying if you are infected by covid in a specific area 

Select Location, date, total_cases , total_deaths , (total_deaths/total_cases)*100 as PercentageDead
from CovidDeaths$
where location like '%states%'
order by 1,2 ;


-- Looking at Total cases vs Population
-- Gives us an idea of the percentage of popuation infected

Select Location, date, total_cases , population , (total_cases/population)*100 as peopleinfected
from CovidDeaths$
where location like '%states%'
order by 1,2 ;

--Looking at contries with highest Infection Rate compared to population 

Select Location, population, max(total_cases) as HighestInfectionCount, max (total_cases/population)*100 as PercentagePopulationInfected
from CovidDeaths$
--where location like '%states%'
group by location, population
order by PercentagePopulationInfected desc ;


--Countries with Highest Death Count per population

Select Location, max(cast (total_deaths as int)) as TotalDeathCount
from CovidDeaths$
--where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc ;




-- Continent segmentation

Select continent, max(cast (total_deaths as int)) as TotalDeathCount
from CovidDeaths$
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc ;


-- Showing continents with heighest death counts 

Select continent, max(cast (total_deaths as int)) as TotalDeathCount
from CovidDeaths$
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc ;


-- Global Numbers 
Select date, sum(new_cases) as totalcases, sum (cast(new_deaths as int) )as totaldeath , sum (cast(new_deaths as int) )/sum(new_cases)*100 as  PercentageDead
from CovidDeaths$
--where location like '%states%'
where continent is not null
group by date 
order by 1,2 ;

--Total Results  
Select sum(new_cases) as totalcases, sum (cast(new_deaths as int) )as totaldeath , sum (cast(new_deaths as int) )/sum(new_cases)*100  as PercentageDead
from CovidDeaths$
--where location like '%states%'
where continent is not null
--group by date 
order by 1,2 ;

--playing with the vaccinations table 
Select *
from covidvaccinations ;

--Joining both the tables 
select *
from CovidDeaths$ d
join covidvaccinations v 
on d.location = v.location
and d.date = v.date ;

--Looking at Total Population vs Vaccinations 
select d.continent, d.location, d.date,d.population, v.new_vaccinations
from CovidDeaths$ d
join covidvaccinations v 
on d.location = v.location
and d.date = v.date
where d.continent is not null
order by 2,3;

--Rolling Count 
select d.continent, d.location, d.date,d.population, v.new_vaccinations, 
sum( convert (int,v.new_vaccinations)) over (partition by d.location order by d.location , d.date ) as rollingcount
from CovidDeaths$ d
join covidvaccinations v 
on d.location = v.location
and d.date = v.date
where d.continent is not null
order by 2,3;



--Using CTE 

with PopvsVac --(location, date, population, new_vaccinations,  rollingcount)
as
(
select d.continent, d.location, d.date,d.population, v.new_vaccinations, 
sum( convert (int,v.new_vaccinations)) over (partition by d.location order by d.location , d.date ) as rollingcount
from CovidDeaths$ d
join covidvaccinations v 
on d.location = v.location
and d.date = v.date
where d.continent is not null
--order by 2,3
)

select *, (rollingcount/population)*100 AS TESTER
from PopvsVac ; 


--temp table 

drop table if exists #PercentagePopulationVaccinated 
create table #PercentagePopulationVaccinated 
(
continent nvarchar (255), 
location nvarchar (255), 
date datetime,
population numeric, 
New_vaccinations numeric, 
rollingcount numeric 
)

insert into #PercentagePopulationVaccinated 

select d.continent, d.location, d.date,d.population, v.new_vaccinations , 
sum( convert (int,v.new_vaccinations)) over (partition by d.location order by d.location , d.date ) as rollingcount
from CovidDeaths$ d
join covidvaccinations v 
on d.location = v.location
and d.date = v.date
where d.continent is not null
--order by 2,3; 

select *
from #PercentagePopulationVaccinated


--Creating a view to store data for later visualizations 

Create view percentagepeopleVaccinated as 

select d.continent, d.location, d.date,d.population, v.new_vaccinations , 
sum( convert (int,v.new_vaccinations)) over (partition by d.location order by d.location , d.date ) as rollingcount
from CovidDeaths$ d
join covidvaccinations v 
on d.location = v.location
and d.date = v.date
where d.continent is not null;

--Cross checking if view is saved 

select *
from percentagepeopleVaccinated;

