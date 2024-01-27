select *
from Portfolio.dbo.CovidDeaths 
order by 3,4

select *
from Portfolio.dbo.CovidVaccinations
order by 3,4

select Location, date, total_cases, total_deaths, population
from Portfolio.dbo.CovidDeaths 
order by 1,2

--total cases vs total deaths

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
from Portfolio.dbo.CovidDeaths 
where location like '%india%'
order by 1,2

--total cases vs population
--percentage of population got covid

select Location, date, total_cases, population, (total_deaths/population)*100 as Deathpercentage
from Portfolio.dbo.CovidDeaths 
--where location like '%india%'
order by 1,2

--country with highest infection rate compare to population

select Location, population, max(total_cases) as highestInfection,max((total_cases/population))*100 as percentagepopulation
from Portfolio.dbo.CovidDeaths 
--where location like '%india%'
Group by Location, Population
order by percentagepopulation desc

--highest death count per population

select Location, max(cast (total_deaths as int)) as totaldeath
from Portfolio.dbo.CovidDeaths 
where continent is not null
Group by Location
order by totaldeath desc

--continent with highest death count per population

select continent, max(cast (total_deaths as int)) as totaldeathcount
from Portfolio.dbo.CovidDeaths 
where continent is not null
Group by continent
order by totaldeathcount desc

--global numbers

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from Portfolio.dbo.CovidDeaths 
where continent is not null
--group by date
order by 1,2

-- total population vs vaccinations

--use CTE

with pepvsvac ( continent, location, date, population, new_vaccinations,RollingPeopleVaccinated)
as(
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
sum(convert(int,new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from  Portfolio.dbo.CovidDeaths dea
join Portfolio.dbo.CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
 where dea.continent is not null
 )
select *, (RollingPeopleVaccinated/population)*100
from pepvsvac

--temp table

drop table if exists #percentagePeopleVaccinated
create table #percentagePeopleVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #percentagePeopleVaccinated

 select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
sum(convert(int,new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from  Portfolio.dbo.CovidDeaths dea
join Portfolio.dbo.CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
 where dea.continent is not null
 select *, (RollingPeopleVaccinated/population)*100
from #percentagePeopleVaccinated

--creat view
create view PercentagePopulationVaccinated as
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
sum(convert(int,new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from  Portfolio.dbo.CovidDeaths dea
join Portfolio.dbo.CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
 where dea.continent is not null

 select *
 from PercentagePopulationVaccinated