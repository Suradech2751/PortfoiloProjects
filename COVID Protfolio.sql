SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4

--EXPLORE DATA เลือกดูข้อมูลในส่วนที่สนใจ
SELECT location, date, total_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

--เริ่มหาข้อมูลเชิงลึกของข้อมูล เช่น หาสัดส่วนคนตายต่อการติดเชื้อ
--LOOKING AT TOTAL DEATS VS TOTAL CASE
--SHOW LIKELIHOOD DYING IF YOU CONTRACT COVID IN US
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

--LOOKING AT TOTAL CASES VS POPULATION
--SHOW WHAT PERCAENTAGE OF POPULATION GOT COVIS
SELECT location, date, population,total_cases,  (total_cases/population)*100 
	AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

--Q: WHICH COUNTY IS THE MOST CONTRACTED COVID
--A: COMPARE BTWEEN INFECTION RATE VS POPULAION EACH SINGLE COUNTRY
SELECT location, population, MAX(total_cases) as HighedtInfectionCountry, 
	MAX(total_cases/population)*100 AS PercentPopulationInfected
	FROM CovidDeaths
GROUP BY location, Population
ORDER BY PercentPopulationInfected DESC

--Q: WHICH COUNTY IS THE HIGHEST DETH
--A: COMPARE BTWEEN DEATH VS POPULAION EACH SINGLE COUNTRY
SELECT location, population, MAX(cast(total_deaths AS int)) as TotalDeathCount,
	MAX(total_deaths/population)*100 AS PercentPopulationDeath
FROM CovidDeaths
	--and location = 'Thailand'
GROUP BY location, population
ORDER BY TotalDeathCount DESC
--เกิดปัญหามีข้อมูลขอลทวีปรวมอยู่ด้วย ซึ่งมันรวมหลายประเทศเข้าด้วยกัน
--ประเทศที่ Continet=Null คือเป็นแค่ข้อมูลทวีปไม่ใช่ประเทศ
--รัน continet is not null เพื่อเอาข้อมูลของทวีปออปกไป
----SELECT *
----FROM PortfolioProject..CovidDeaths
----WHERE continent is not null
----ORDER BY 3,4
SELECT location, MAX(cast(total_deaths AS int)) as TotalDeathCount
	--, MAX(total_deaths/population)*100 AS PercentPopulationDeath
FROM CovidDeaths
WHERE continent is null 
	--and location = 'Thailand'
GROUP BY location
ORDER BY TotalDeathCount DESC
--
SELECT continent, MAX(cast(total_deaths AS int)) as TotalDeathCount
	--, MAX(total_deaths/population)*100 AS PercentPopulationDeath
FROM CovidDeaths
WHERE continent is not null 
	--and location = 'Thailand'
GROUP BY continent
ORDER BY TotalDeathCount DESC

--SHOWING CONTINENT WITH THE HIGHEST DEATH COUNT PER POPULATION
SELECT continent, MAX(cast(total_deaths AS int)) as TotalDeathCount
	--, MAX(total_deaths/population)*100 AS PercentPopulationDeath
FROM CovidDeaths
WHERE continent is not null 
GROUP BY continent
ORDER BY TotalDeathCount DESC

--GLOBAL NUMBER
SELECT date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, 
	(SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
FROM CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--OVER ALL SUM OF TOTAL CASES AND TOTAL DEATHS
SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, 
	(SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
FROM CovidDeaths
WHERE continent is not null

--GROUP BY date
ORDER BY 1,2

--LOOKING AT TOTAL POPULATION VS TOTAL VACCINATION
--JOIN TABLE BY LOCATION AND DATE
--บวกจำนวนคนฉีดไปเรื่อยๆ เป็น Rolling
SELECT Deaths.continent, Deaths.location, Deaths.date, deaths.population, 
	Vaccines.new_vaccinations, SUM(CONVERT(int,Vaccines.new_vaccinations)) 
	over (PARTITION BY Deaths.location 
	order by deaths.location,deaths.date) as RollingPeopleVaccineated,
	(RollingPeopleVaccinated/population)*100
FROM CovidDeaths as Deaths
JOIN CovidVaccinations as Vaccines
	on Deaths.location = Vaccines.location
	and Deaths.date = Vaccines.date
WHERE Deaths.continent is not null
ORDER BY 2,3

--USE CTE 
WITH PopVsVac (Continent, Location, date, Population, New_Vaccinations, RollingPeopleVaccineated)
AS 
(SELECT Deaths.continent, Deaths.location, Deaths.date, deaths.population, 
	Vaccines.new_vaccinations, SUM(CONVERT(int,Vaccines.new_vaccinations)) 
	over (PARTITION BY Deaths.location 
	order by deaths.location,deaths.date) as RollingPeopleVaccineated
	--(RollingPeopleVaccinated/population)*100
FROM CovidDeaths as Deaths
JOIN CovidVaccinations as Vaccines
	on Deaths.location = Vaccines.location
	and Deaths.date = Vaccines.date
WHERE Deaths.continent is not null)
--ORDER BY 2,3
SELECT * ,(RollingPeopleVaccineated/Population)*100 AS RateOFVac
FROM PopVsVac

--USE TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(225),
Location nvarchar(225),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT Deaths.continent, Deaths.location, Deaths.date, deaths.population, 
	Vaccines.new_vaccinations, SUM(CONVERT(int,Vaccines.new_vaccinations)) 
	over (PARTITION BY Deaths.location 
	order by deaths.location,deaths.date) as RollingPeopleVaccineated
	--(RollingPeopleVaccinated/population)*100
FROM CovidDeaths as Deaths
JOIN CovidVaccinations as Vaccines
	on Deaths.location = Vaccines.location
	and Deaths.date = Vaccines.date
WHERE Deaths.continent is not null

SELECT * ,(RollingPeopleVaccinated/Population)*100 AS RateOFVac
FROM #PercentPopulationVaccinated

--CREATE A VIEW

CREATE VIEW PercentPopulationVaccinated as
SELECT Deaths.continent, Deaths.location, Deaths.date, deaths.population, 
	Vaccines.new_vaccinations, SUM(CONVERT(int,Vaccines.new_vaccinations)) 
	over (PARTITION BY Deaths.location 
	order by deaths.location,deaths.date) as RollingPeopleVaccineated
	--(RollingPeopleVaccinated/population)*100
FROM CovidDeaths as Deaths
JOIN CovidVaccinations as Vaccines
	on Deaths.location = Vaccines.location
	and Deaths.date = Vaccines.date
Where Deaths.continent is not null

SELECT *
FROM PercentPopulationVaccinated