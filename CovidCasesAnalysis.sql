use PortfolioProject;

select * from CovidDeaths;
-- Select Data 
select Location, date, total_cases,new_cases, total_deaths,population 
from CovidDeaths
where continent is not null
order by 1,2;

--Total Cases Vs Total Deaths
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from CovidDeaths 
where location like '%Nepal%'
and continent is not null
order by 1,2;

--Total cases Vs Population
select location, date, population,total_cases, (total_cases/population)*100 as Death_Percentage
from CovidDeaths 
where continent is not null and 
location like '%States%'
order by 1,2;

--Highest Infection Rate VS Population
select location,  population, max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PecentageInfected
from CovidDeaths 
group by location, population
order by PecentageInfected desc;


-- Data By location
select location, max(cast(total_deaths as int)) as HighestDeathCount
from CovidDeaths 
where continent is null
group by location
order by HighestDeathCount desc;

-- Data by Continent
select continent, max(cast(total_deaths as int)) as HighestDeathCount
from CovidDeaths 
where continent is not null
group by continent
order by HighestDeathCount desc;

--Highest Death Count Vs Population
select location, max(cast(total_deaths as int)) as HighestDeathCount
from CovidDeaths 
where continent is not null
group by location
order by HighestDeathCount desc;


-- Global Data Numbers
select date, sum(total_cases) Total_Cases, 
sum(cast(new_deaths as int)) as Total_Deaths,
(sum(cast(new_deaths as int))/ sum(new_cases))*100 as Death_Percentage
from CovidDeaths 
where continent is not null
group by date
order by 1,2 ; 

--Only Total Values
select sum(total_cases) Total_Cases, 
sum(cast(new_deaths as int)) as Total_Deaths,
(sum(cast(new_deaths as int))/ sum(new_cases))*100 as Death_Percentage
from CovidDeaths 
where continent is not null
order by 1,2 ; 

--Working with CovidVacinations

--Total Population vs Vacinnations
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(cast(new_vaccinations as int))over (partition by  cd.location)  
from CovidDeaths as cd
join CovidVaccinations as cv
on cd.location = cv.location and cd.date = cv.date
where cd.continent is not null
order by 2,3;

------------------OR--------------------------------------
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(convert(int,new_vaccinations))over (partition by  cd.location order by cd.location, cd.date) as Rolling_People_Vaccinations
from CovidDeaths as cd
join CovidVaccinations as cv
on cd.location = cv.location and cd.date = cv.date
where cd.continent is not null
order by 2,3;

--use CTE (Common Table Expression)
with popvsVac(Continent, Location, Date, Population,new_vaccinations, Rolling_People_Vaccinations)
as 
(
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(convert(int,new_vaccinations))over (partition by  cd.location order by cd.location, cd.date) as Rolling_People_Vaccinations
from CovidDeaths as cd
join CovidVaccinations as cv
on cd.location = cv.location and cd.date = cv.date
where cd.continent is not null)
select *, (Rolling_People_Vaccinations/Population)*100 as VaccinePrentage from popvsVac;


Drop table if exists #PercentageOfPopulationVacinated
--TEMP Table
create table #PercentageOfPopulationVacinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentageOfPopulationVacinated

select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(convert(int,cv.new_vaccinations))over (partition by  cd.location order by cd.location, cd.date) as RollingPeopleVaccinations
from CovidDeaths as cd
join CovidVaccinations as cv
on cd.location = cv.location and cd.date = cv.date
where cd.continent is not null

select *, (RollingPeopleVaccinated/Population)*100 as VaccinePrentage from #PercentageOfPopulationVacinated;


-- Creating View to store data for later visualiation

create view PercentageOfPopulationVacinated as 
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(convert(int,cv.new_vaccinations))over (partition by  cd.location order by cd.location, cd.date) as RollingPeopleVaccinations
from CovidDeaths as cd
join CovidVaccinations as cv
	on cd.location = cv.location 
	and cd.date = cv.date
where cd.continent is not null