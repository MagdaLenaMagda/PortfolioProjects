/*
Covid 19 Data Exploration
*/
Select *
From PortfolioProject..covid_deaths
where continent is not null
Order by 3,4


Select location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
From PortfolioProject..covid_deaths
Where continent is not null 
Order by 1,2


Select location, date, Population, total_cases, (cast(total_cases as float)/cast(Population as float))*100 as PercentPopulationInfected
From PortfolioProject..covid_deaths
Where continent is not null
Order by 1,2


Select location, Population, MAX(total_cases) as HighestInfectionRate, MAX((cast(total_cases as float)/cast(Population as float))*100) as PercentPopulationInfected
From PortfolioProject..covid_deaths
Group by location, Population 
Order by PercentPopulationInfected desc


Select location, Population, MAX(cast(total_deaths as int)) as HighestDeathCount
From PortfolioProject..covid_deaths
Where continent is not null
Group by location, Population
Order by HighestDeathCount desc


Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject.. covid_deaths
Where continent is not null
Group by continent 
Order by TotalDeathCount desc


Select continent, location, MAX(reproduction_rate) as MaxReproductionRate
From PortfolioProject..covid_deaths
Where continent is not null
Group by continent, location
Order by MaxReproductionRate desc


Select Year(date) as Year, sum(cast(icu_patients as int)) as EmergencyRoomPatients, sum(cast(hosp_patients as int)) as HospitalizedPatients
From PortfolioProject..covid_deaths
Group by Year(date)
Order by 2 desc


Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..covid_deaths
where continent is not null 
order by 1,2


Select dea.continent, dea.location, dea.date, dea.Population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..covid_deaths as dea
Join PortfolioProject..covid_vaccine as vac
on dea.location = vac.location and dea.date = vac.date 
where dea.continent is not null 
order by 2,3


With ReprvsVac (reproduction_rate, people_fully_vaccinated, ReproductionRate)
as
(
Select dea.reproduction_rate, vac.people_fully_vaccinated,
Case 
	When cast(dea.reproduction_rate as float) < 1 then 'Low'
	When cast(dea.reproduction_rate as float) between 1 and 2 then 'Medium'
	Else 'High'
End as ReproductionRate 
From PortfolioProject..covid_deaths as dea
Join PortfolioProject..covid_vaccine as vac
on dea.location = vac.location and dea.date = vac.date 
where dea.continent is not null and dea.reproduction_rate is not null
)
Select ReproductionRate, sum(cast(people_fully_vaccinated as float)) as VaccinatedPeopleSum
From ReprvsVac
Group by ReproductionRate
Order by VaccinatedPeopleSum


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
, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..covid_deaths dea
Join PortfolioProject..covid_vaccine vac
	On dea.location = vac.location
	and dea.date = vac.date

Select *, (RollingPeopleVaccinated/Population)*100 as PercentPopulationVaccinated
From #PercentPopulationVaccinated


