SELECT 
    *
FROM
    project_portfolio.coviddeaths
WHERE
    continent IS NOT NULL
ORDER BY 3 , 4;

SELECT 
    *
FROM
    project_portfolio.covidvaccinations
ORDER BY 3 , 4;




-- select data we are using
SELECT 
    location,
    date,
    new_cases,
    total_deaths,
    total_cases,
    population
FROM
    project_portfolio.coviddeaths
ORDER BY 1 , 2;

-- looking at total cases vr total deaths
-- shows likelihoodof dying if you contract covid in Ghana
SELECT 
    location,
    date,
    total_deaths,
    total_cases,
    (total_deaths / total_cases) * 100 AS death_percentage
FROM
    project_portfolio.coviddeaths
WHERE
    location LIKE 'ghana'
ORDER BY 1 , 2;

-- looking at total cases vs populaion
-- shows what percentage of popullation got covid

SELECT 
    location,
    date,
    population,
    total_cases,
    (total_cases / population) * 100 AS percent_population_infected
FROM
    project_portfolio.coviddeaths
WHERE
    location LIKE 'ghana'
ORDER BY 1 , 2;

-- looking at countries with highest infection rate compared with
SELECT 
    location,
    population,
    MAX(total_cases) AS highest_infection_count,
    MAX(total_cases / population) * 100 AS percent_population_infected
FROM
    project_portfolio.coviddeaths
GROUP BY location , population
ORDER BY percent_population_infected DESC;

-- Showing countries with highest death count per popullation
SELECT 
    location, MAX(total_deaths) AS total_death_count
FROM
    project_portfolio.coviddeaths
WHERE
    continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC;

-- Breaking Things Down by Continent
-- Showing Continents With Highest Death Count as per popullation
SELECT 
    continent, MAX(total_deaths) AS total_death_count
FROM
    project_portfolio.coviddeaths
WHERE
    continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC;

-- Global Numbers
SELECT 
    SUM(new_cases) AS total_cases,
    SUM(new_deaths) AS total_death,
    SUM(new_deaths) / SUM(new_cases) * 100 AS death_percentage
FROM
    project_portfolio.coviddeaths
WHERE
    continent IS NOT NULL
ORDER BY 1 , 2;


-- looking at total popullation vs vacination
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations
FROM
    project_portfolio.coviddeaths dea
        JOIN
    project_portfolio.covidvaccinations vac ON dea.location = vac.location
        AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL
ORDER BY 2 , 3;

SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vacinated
FROM
    project_portfolio.coviddeaths dea
        JOIN
    project_portfolio.covidvaccinations vac ON dea.location = vac.location
        AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL
ORDER BY 2,3;


-- use CTE
with pops_vac( continent,location,date,population,new_vacination,rolling_people_vacinated)
as(
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vacinated
FROM
    project_portfolio.coviddeaths dea
        JOIN
    project_portfolio.covidvaccinations vac ON dea.location = vac.location
        AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL)
SELECT *,(rolling_people_vacinated/ population)*100 as percent_population_vacinated
FROM pops_vac
ORDER BY location, date;

-- Temp table
-- 1. Create the table
CREATE TABLE percent_population_vacinated (
    continent VARCHAR(255),
    location VARCHAR(255),
    date DATE,
    population DECIMAL(15 , 2 ),
    rolling_people_vacinated DECIMAL(15 , 2 )
);
INSERT INTO percent_population_vacinated
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vacinated
FROM
    project_portfolio.coviddeaths dea
JOIN
    project_portfolio.covidvaccinations vac 
    ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;
SELECT 
    *,
    (rolling_people_vacinated / population) * 100 AS percent_population_vacinated
FROM
    percent_population_vacinated
ORDER BY location , date;

-- creating views to store data for later visualization

create view  percent_pop_vacinated as
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vacinated
FROM
    project_portfolio.coviddeaths dea
        JOIN
    project_portfolio.covidvaccinations vac ON dea.location = vac.location
        AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL
-- ORDER BY 2,3;




