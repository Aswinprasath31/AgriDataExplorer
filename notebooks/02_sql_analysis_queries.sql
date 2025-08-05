-- 1. Year-wise Trend of Rice Production (Top 3 States)
SELECT Year, State_Name, SUM(RICE_PRODUCTION) AS Total_Rice
FROM agri_data
GROUP BY Year, State_Name
ORDER BY Total_Rice DESC
LIMIT 3;

-- 2. Districts with Highest Groundnut Production (2020)
SELECT Dist_Name, GROUNDNUT_PRODUCTION
FROM agri_data
WHERE Year = 2020
ORDER BY GROUNDNUT_PRODUCTION DESC
LIMIT 10;

-- 3. Oilseed Production Growth Over 5 Years
SELECT State_Name, 
       MAX(Year) AS Latest_Year,
       MIN(Year) AS Earliest_Year,
       MAX(OILSEEDS_PRODUCTION) - MIN(OILSEEDS_PRODUCTION) AS Growth
FROM agri_data
GROUP BY State_Name
ORDER BY Growth DESC
LIMIT 5;

-- 4. Average Maize Yield per State
SELECT State_Name, AVG(MAIZE_YIELD) AS Avg_Maize_Yield
FROM agri_data
GROUP BY State_Name;








-- 1. Year-wise Trend of Rice Production Across States (Top 3 each year)

SELECT year, state_name, rice_production_1000_tons
FROM ( SELECT year, state_name, rice_production_1000_tons,
        ROW_NUMBER() OVER (PARTITION BY year ORDER BY rice_production_1000_tons DESC) AS rank1
    FROM agriculture_data
) AS ranked_data
WHERE rank1 <= 3
ORDER BY year, rank1;

-- 2. Top 5 Districts by Wheat Yield Increase Over the Last 5 Years


SELECT dist_name,
       MAX(wheat_yield_kg_per_ha) - MIN(wheat_yield_kg_per_ha) AS yield_increase
FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY dist_name ORDER BY year DESC) AS rank2
    FROM agriculture_data
) AS sub
WHERE rank2 <= 5
GROUP BY dist_name
ORDER BY yield_increase DESC
LIMIT 5;

-- 3. States with Highest Growth in Oilseed Production (5-Year Growth Rate)

-- Step 1: Retrieve initial and final production values for each state over the last 5 years


WITH GrowthData AS (
    SELECT 
        state_name,
        year,
        SUM(oilseeds_production_1000_tons) AS production
    FROM agriculture_data
    WHERE year BETWEEN (SELECT MAX(year) - 4 FROM agriculture_data) AND (SELECT MAX(year) FROM agriculture_data)
    GROUP BY state_name, year
)
-- Step 2: Calculate growth rate for each state and show yearly results


SELECT 
    gd.year,
    gd.state_name, 
    (gd.production - LAG(gd.production) OVER (PARTITION BY gd.state_name ORDER BY gd.year)) / LAG(gd.production) OVER (PARTITION BY gd.state_name ORDER BY gd.year) * 100 AS growth_rate
FROM GrowthData gd
ORDER BY gd.state_name, gd.year;

-- 4. District-wise Correlation Between Area and Production (Rice, Wheat, Maize)


SELECT 
    dist_name,
    SUM(rice_area_1000_ha) AS rice_area,
    SUM(rice_production_1000_tons) AS rice_production,
    SUM(wheat_area_1000_ha) AS wheat_area,
    SUM(wheat_production_1000_tons) AS wheat_production,
    SUM(maize_area_1000_ha) AS maize_area,
    SUM(maize_production_1000_tons) AS maize_production
FROM agriculture_data
GROUP BY dist_name
ORDER BY dist_name;

-- 5.Yearly Production Growth of Cotton in Top 5 Cotton Producing States


WITH top_cotton_states AS (
    SELECT state_name
    FROM agriculture_data
    GROUP BY state_name
    ORDER BY SUM(COTTON_PRODUCTION_1000_tons) DESC   -- note the back-ticks
    LIMIT 5
)
SELECT a.year, a.state_name, SUM(a.COTTON_PRODUCTION_1000_tons) AS yearly_cotton_production
FROM agriculture_data AS a
JOIN top_cotton_states AS t
  ON a.state_name = t.state_name
GROUP BY a.year, a.state_name
ORDER BY a.state_name, a.year;

-- 6.Districts with the Highest Groundnut Production in 2020

SELECT dist_name, state_name, groundnut_production_1000_tons AS groundnut_production
FROM agriculture_data
WHERE year = 2020
ORDER BY groundnut_production_1000_tons asc
LIMIT 10;

-- 7.Annual Average Maize Yield Across All States

SELECT state_name, Year,avg(maize_production_1000_tons) as maize_Avg_yield
FROM agriculture_data
group BY Year,state_name
order by state_name asc;

-- 8.Total Area Cultivated for Oilseeds in Each State--

Select state_name, sum(oilseeds_area_1000_ha) as area_cultivated
FROM agriculture_data
group by state_name
order by state_name asc;

-- 9.Districts with the Highest Rice Yield


Select dist_name, sum(rice_yield_kg_per_ha) as Rice_Yield
FROM agriculture_data
group by dist_name
order by Rice_Yield desc;

-- 10.Compare the Production of Wheat and Rice for the Top 5 States Over 10 Years

SELECT 
    a.year,
    a.state_name,
    SUM(a.wheat_production_1000_tons) AS wheat_production,
    SUM(a.rice_production_1000_tons) AS rice_production
FROM agriculture_data a
JOIN top_5_states t ON a.state_name = t.state_name
WHERE a.year BETWEEN 2011 AND 2020
GROUP BY a.year, a.state_name
ORDER BY a.state_name, a.year;

