-- Select the data that is going to be used

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

-- looking at total cases compared to total deaths
-- Will show the percentage chance of dying if infected with COVID 19 (does not take into account variables such as health previous to infection or comorbidities)


Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathRate
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2


-- looking as total cases compared to population
-- Shows what percentage of population got Covid

Select location, date, population, total_cases, (total_cases/population)*100 as InfectionRate
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2


-- looking at countries with the highest infection rate compared to population 

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected 
From PortfolioProject..CovidDeaths
--Where location like '%states%'
GROUP BY location, population
order by PercentPopulationInfected desc 

-- showing countries with highest death count per population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null
GROUP BY location
order by TotalDeathCount desc

-- I am going to break the data down by continent and showing the highest death counts by continent

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null
GROUP BY continent
order by TotalDeathCount desc


-- global COVID numbers



Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/Sum(new_cases)*100
as DeathRate
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null
--group by date
order by 1,2


-- joining the covid deaths table with the covid vaccinations table


Select *
From PortfolioProject..CovidDeaths dea	
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date


-- looking at total population vs vaccinations


Select dea.continent, dea.location, dea.date, dea.continent, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location,
dea.Date) as PeopleVaccinated
--, (PeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea	
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- use CTE


with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, PeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.continent, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.date) as PeopleVaccinated
--, (PeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea	
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
 

Select *, (PeopleVaccinated/Population)*100
From PopvsVac 



-- temp table


create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
PeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated

Select dea.continent, dea.location, dea.date, dea.continent, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as PeopleVaccinated
--, (PeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea	
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *(PeopleVaccinated/population)*100
From PercentPopulationVaccinated


-- creating view to store data for vizualizations 


create View GlobalInfections as
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/Sum(new_cases)*100
as DeathRate
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null
--group by date
--order by 1,2