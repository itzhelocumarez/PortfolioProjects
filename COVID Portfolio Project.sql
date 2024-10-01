  Select *
  FROM PortfolioProject..CovidDeaths
  Where continent is not null
  Order By 3,4

  --Select *
  --From PortfolioProject..CovidVaccinations

  -- Select Data to be used

  Select Location,date, total_cases, new_cases, total_deaths, population
  FROM PortfolioProject..CovidDeaths
  order by 1,2


  -- Looking at Total Cases vs Total Deaths
  -- Shows likelihood of dying of Covid in DR

  Select Location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
  FROM PortfolioProject..CovidDeaths
  Where location like '%Dominican%'
  order by 1,2

  -- Looking at the Total Cases vs Population
  -- Percentage of population got Covid

  Select Location,date,population,total_cases, (total_cases/population)*100 AS PercentPopulationInfected
  FROM PortfolioProject..CovidDeaths
 -- Where location like '%States%'
  order by 1,2

  -- Looking at Countries with Highest Infection Rate compared to population

Select Location,population, MAX (total_cases) As Hightest_Infection_Count, MAX ((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
 -- Where location like '%States%'
Group by Location, population
order by PercentPopulationInfected DESC

-- Showing Countries with Highest Death Count per Population

Select Location,MAX(cast(Total_deaths as int)) As TotalDeathCount
FROM PortfolioProject..CovidDeaths
 -- Where location like '%States%'
Where continent is not null
Group by Location
order by TotalDeathCount DESC

-- Showing continent with the hights death count per population

Select continent, MAX(cast(Total_deaths as int)) As TotalDeathCount
FROM PortfolioProject..CovidDeaths
 -- Where location like '%States%'
Where continent is not null
Group by continent
order by TotalDeathCount DESC


-- GLOBAL NUMBERS

Select SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) As Total_Deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)* 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
  --Where location like '%Dominican%'
Where continent is not null
--Group by date
order by 1,2


-- Looking at Total Population vs Vaccinations


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT (int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) As RollingPeopleVaccinated
From PortfolioProject..CovidDeaths DEA
Join PortfolioProject..CovidVaccinations VAC
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 1,2,3

--USE CTE
WITH PopsvsVac (Continet, Location, Date, Population, new_vacccinations, RollingPeopleVaccinated)
As

(

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT (int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) As RollingPeopleVaccinated
From PortfolioProject..CovidDeaths DEA
Join PortfolioProject..CovidVaccinations VAC
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
-- Order by 2,3

)

Select *, (RollingPeopleVaccinated/Population)*100
From PopsvsVac



-- TEMP TABLE

DROP table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated

(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT (int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) As RollingPeopleVaccinated
From PortfolioProject..CovidDeaths DEA
Join PortfolioProject..CovidVaccinations VAC
	ON dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
-- Order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualization

Create view PercentPopulationVaccinated as

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT (int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) As RollingPeopleVaccinated
From PortfolioProject..CovidDeaths DEA
Join PortfolioProject..CovidVaccinations VAC
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
-- Order by 2,3

Select *
From PercentPopulationVaccinated