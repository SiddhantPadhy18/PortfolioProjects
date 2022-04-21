/*select * from CovidDeaths order by 3,4
select * from CovidVaccinations order by 3,4*/

select location, date, total_cases, new_cases, total_deaths, population 
from PortfolioProject..CovidDeaths

--Looking at Total Cases vs Total Deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
from PortfolioProject..CovidDeaths order by 1,2

--Shows likelyhood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
from PortfolioProject..CovidDeaths where location like 'India' order by 1,2

--Shows what percentage of people got covid (TotalCases Vs Population)

select location, date, total_cases, population,(total_cases/population)*100 as PercentagePeopleInfected 
from PortfolioProject..CovidDeaths where location like 'India' order by 1,2

--Looking at the countries with highest infection rate compared to Population

select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentagePeopleInfected 
from PortfolioProject..CovidDeaths
group by location, population
order by PercentagePeopleInfected desc

--Showing countries with Highest Death count per Population

select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

--Break things by Continent

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

--Global Numbers(Each Day)

Select date, sum(new_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_Death,
sum(cast(new_deaths as int))/sum(new_cases) * 100 as DeathPercentage 
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

--Gloal Numbers(Total)

Select sum(new_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_Death,
sum(cast(new_deaths as int))/sum(new_cases) * 100 as DeathPercentage 
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Looking at Total Population vs Total Vaccination
-- Using CTE


with PopvsVac (continent, location, date, population, new_vaccinations, RollingVaccination)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingVaccination
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingVaccination/population)*100 as Percentage from PopvsVac

-- using Temp Table


create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingVaccination numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingVaccination
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3


select *, (RollingVaccination/population)*100 as Percentage from #PercentPopulationVaccinated order by 2,3

-- Creating a View

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingVaccination
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

select * from PercentPopulationVaccinated