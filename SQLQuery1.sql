select * 
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select * 
--from PortfolioProject..CovidVaccination
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

-- Lookin at the Total Cases VS Total Deaths
-- Shows the likelihood of dying if you have covid in your country
select location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%india%'
order by 1,2

--Looking at Total cases vs Population
--Shows what percenatge of population got covid
select location, date, population, total_cases, (cast(total_cases as float)/cast(population as float))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where location like '%india%'
order by 1,2

--Looking at countries with Highest Infection Rate compared to population
select location, population, max(total_cases) as HighestInfectionCount, max((cast(total_cases as float)/cast(population as float)))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%india%'
group by location, population
order by PercentPopulationInfected desc


--Showing countries with highest death count per Population
select location, Max(cast (total_deaths as int)) as TotalDeathCounts 
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCounts desc

--Showing continents with highest death count per population
select continent, Max(cast (total_deaths as int)) as TotalDeathCounts 
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCounts desc

--Global Numbers

--select date, sum(cast(new_cases as float)), sum(cast(new_deaths as float)), sum(cast(new_deaths as float))/(sum(cast(new_cases as float,)))*100 as DeathPercentage
--from PortfolioProject..CovidDeaths
----where location like '%india%'
--where continent is null
--group by date
--order by 1,2

select date, sum(cast(new_cases as float)) as total_cases, sum(cast(new_deaths as float)) as total_deaths, 
sum(cast(new_deaths as float))/(NULLIF(sum(cast(new_cases as float)), 0))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
group by date
order by 1,2


select sum(cast(new_cases as float)) as total_cases, sum(cast(new_deaths as float)) as total_deaths, 
sum(cast(new_deaths as float))/(NULLIF(sum(cast(new_cases as float)), 0))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
order by 1,2

--Looking at Total Populations VS Vaccinations 


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(float, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

with popvsvac (continent, location, date, population, new_vaccination, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(float, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from popvsvac


--Temp table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(float, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

-- creating view for data visualization


create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(float, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

drop view PercentPopulationVaccinated

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(float, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null


select * from PercentPopulationVaccinated

--view for death percentage in india
CREATE VIEW DeathPercentageIndia AS
select location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%india%'
--order by 1,2

select * from DeathPercentageIndia

--view for percent of population infected in india
CREATE VIEW PercentPopInfIndia AS
select location, date, population, total_cases, (cast(total_cases as float)/cast(population as float))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where location like '%india%'

select * from PercentPopInfIndia