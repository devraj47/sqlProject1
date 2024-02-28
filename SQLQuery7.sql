select * from coviddeaths
where continent is not null
order by 3,4


--select * from covidvaccinations
--order by 3,4 

select location, date, total_cases, new_cases, total_deaths, population
from coviddeaths
where continent is not null
order by 1,2


--total cases vs total deaths

--select location, date, total_cases, total_deaths, (Total_deaths/Total_cases)
--from coviddeaths
--order by 1,2

--above command did not work so used this command
Select Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
From coviddeaths
where location like '%states%'
and continent is not null
order by 1,2

--looking at Total cases vs population
select location, date, total_cases, population, (Total_cases/population) *100 as afctedRate
from coviddeaths
where location like '%states%' 
order by 1,2


-- countries with high afcted rate
select location, population, max(total_cases) as highestInfCount, max((Total_cases/population))*100 as afctedRate
from coviddeaths
--where location like '%states%' 
group by location, population
order by 4 desc


--highest deathcount per population
select location, max(cast(total_deaths as int))as totalDeathCount
from coviddeaths
--where location like '%states%' 
where continent is not null
group by location
order by totalDeathCount desc


--breaking things by continent
--continent with highest death count

select continent, max(cast(total_deaths as int))as totalDeathCount
from coviddeaths
--where location like '%states%' 
where continent is not null 
group by continent
order by totalDeathCount desc



--global numbers
--Select date,  sum(new_cases), sum(new_deaths), sum(cast(new_deaths as  int))/nullif(sum(cast(new_cases as int)),0)*100 as deathpercentage

Select date,  sum(new_cases), sum(new_deaths),sum(CONVERT(float, new_deaths)) / sum(NULLIF(CONVERT(float, new_cases), 0))*100 as DeathPercentage
From coviddeaths
--where location like '%states%'
where continent is not null and new_deaths is not null
group by date
order by 1,2


-- total population vs vaccinations

select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
sum(convert(float,vac.new_vaccinations )) over (partition by dea.location order by dea.location,
dea.date) as rollingpeoplevaccinated
--, (rollingpeoplevaccinated/population)
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--Use CTE
with popvsvac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
sum(convert(float,vac.new_vaccinations )) over (partition by dea.location order by dea.location,
dea.date) as rollingpeoplevaccinated
--, (rollingpeoplevaccinated/population)
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select *, (rollingpeoplevaccinated/population) * 100 from popvsvac


-- temp table
drop table if exists #percentPopulationVaccinated

create table #percentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

Insert into #percentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
sum(convert(float,vac.new_vaccinations )) over (partition by dea.location order by dea.location,
dea.date) as rollingpeoplevaccinated
--, (rollingpeoplevaccinated/population)
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (rollingpeoplevaccinated/population)*100 

from #percentpopulationvaccinated



--creating views to store later visulization

create view percentpopulationvaccinated as
select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
sum(convert(float,vac.new_vaccinations )) over (partition by dea.location order by dea.location,
dea.date) as rollingpeoplevaccinated
--, (rollingpeoplevaccinated/population)
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from percentpopulationvaccinated

where rollingpeoplevaccinated is not null
and new_vaccinations is not null
