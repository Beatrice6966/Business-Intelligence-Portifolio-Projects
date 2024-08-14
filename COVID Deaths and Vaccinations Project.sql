select *
from COVIDPortifolioProject..CovidDeaths$
where continent is not null
order by 3,4

--select *
--from COVIDPortifolioProject..CovidVaccinations$

--Select Data that we will be using
select location, date, total_cases, new_cases, total_deaths, population
from COVIDPortifolioProject..CovidDeaths$
order by 1, 2

-- Looking at total cases vs total deaths
--Shows the likelihood of dying when you are have COVID
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from COVIDPortifolioProject..CovidDeaths$
where location like '%tanzania%'
order by 1,2

--Looking at Total cases vs Population
--What percentage of population got COVID
select location, date,population, total_cases, (total_cases/population)*100 as PopulationPercentInfected
from COVIDPortifolioProject..CovidDeaths$
where location like '%tanzania%'
order by 1,2

--Looking at Countries with Highest infection Rate compared to population
select location,population, MAX(total_cases) as HighestInfectionCount, MAX(total_deaths) as HighestDeath,
MAX(total_cases/population)*100 as PopulationPercentInfected
from COVIDPortifolioProject..CovidDeaths$
group by location, population
order by PopulationPercentInfected desc

--Countries with Highest Death Count per Population
select location,  MAX(cast(total_deaths as int)) as TotalDeathcount
from COVIDPortifolioProject..CovidDeaths$
where continent is not null
group by location
order by TotalDeathcount desc



--LET'S BREAK THINGS DOWN BY CONTINENT


--Showing continents with the highest death Count per population
select continent,  MAX(cast(total_deaths as int)) as TotalDeathcount
from COVIDPortifolioProject..CovidDeaths$
--where continent is not null
group by continent
order by TotalDeathcount desc


--GLOBAL NUMBERS


select SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/ SUM(new_cases) *100 as DeathPercentage
from COVIDPortifolioProject..CovidDeaths$
--where location like '%tanzania%'
where continent is not null
--group by date
order by 1,2


select *
from COVIDPortifolioProject..CovidDeaths$ dea
join COVIDPortifolioProject..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date= vac.date

--Looking at Total Population Vs Vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from COVIDPortifolioProject..CovidDeaths$ dea
join COVIDPortifolioProject..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date= vac.date
where dea.continent is not null
order by 1,2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From COVIDPortifolioProject..CovidDeaths$ dea
Join COVIDPortifolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,ISNULL(vac.new_vaccinations,0))) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From COVIDPortifolioProject..CovidDeaths$ dea
Join COVIDPortifolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations
DROP VIEW IF EXISTS PercentPopulationVaccinated; 

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From COVIDPortifolioProject..CovidDeaths$ dea
Join COVIDPortifolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

SELECT * 
FROM INFORMATION_SCHEMA.VIEWS 
WHERE TABLE_NAME = 'PercentPopulationVaccinated';
