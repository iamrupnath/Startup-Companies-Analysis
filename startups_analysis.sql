-- Active: 1755704517343@@127.0.0.1@3306@startupdb
CREATE DATABASE StartupDB;

USE StartupDB;

CREATE TABLE Startups (
    Startup_ID INT PRIMARY KEY,
    Company_Name VARCHAR(255) NOT NULL,
    Industry VARCHAR(100),
    One_Line_Pitch TEXT,
    Founding_Year INT,
    Headquarters_Location VARCHAR(255),
    Funding_Stage VARCHAR(50),
    Last_Funding_Amount_USD_Millions DECIMAL(15, 2),
    Number_of_Employees INT,
    Website VARCHAR(255),
    LinkedIn_Profile VARCHAR(255),
    Twitter_Handle VARCHAR(100),
    CEO_Name VARCHAR(100),
    Core_Technology VARCHAR(100),
    Market_Size_Billion_USD DECIMAL(10, 2)
);

SELECT * FROM startups LIMIT 5;

-- Q1. Find the top 5 industries with the highest average funding amount, excluding startups with NULL funding values.

SELECT Industry, ROUND(
        AVG(
            Last_Funding_Amount_USD_Millions
        ), 2
    ) AS Avg_Funding
FROM Startups
WHERE
    Last_Funding_Amount_USD_Millions IS NOT NULL
GROUP BY
    Industry
ORDER BY Avg_Funding DESC
LIMIT 5;

-- Q2. List the startups founded after 2015 that have more employees than the average number of employees across all startups.

SELECT
    Company_Name,
    Industry,
    Founding_Year,
    Number_of_Employees
FROM Startups
WHERE
    Founding_Year > 2015
    AND Number_of_Employees > (
        SELECT AVG(Number_of_Employees)
        FROM Startups
        WHERE
            Number_of_Employees IS NOT NULL
    );

-- Q3. Identify the headquarters locations that host at least 1 startups, and calculate the total funding raised in each.

SELECT
    Headquarters_Location,
    COUNT(*) AS Startup_Count,
    SUM(
        Last_Funding_Amount_USD_Millions
    ) AS Total_Funding
FROM Startups
WHERE
    Last_Funding_Amount_USD_Millions IS NOT NULL
GROUP BY
    Headquarters_Location
HAVING
    COUNT(*) >= 1
ORDER BY Total_Funding DESC;

-- Q4. For each funding stage, find the startup with the maximum funding amount and display its company name, industry, and funding.

WITH
    RankedStartups AS (
        SELECT
            Funding_Stage,
            Company_Name,
            Industry,
            Last_Funding_Amount_USD_Millions,
            ROW_NUMBER() OVER (
                PARTITION BY
                    Funding_Stage
                ORDER BY
                    Last_Funding_Amount_USD_Millions DESC
            ) AS rn
        FROM startups
        WHERE
            Last_Funding_Amount_USD_Millions IS NOT NULL
    )
SELECT
    Funding_Stage,
    Company_Name,
    Industry,
    Last_Funding_Amount_USD_Millions
FROM RankedStartups
WHERE
    rn = 1
ORDER BY
    Last_Funding_Amount_USD_Millions DESC;

-- Q5. Rank startups within each industry by their funding amount and select only the top 3 per industry.

WITH
    RankedStartups AS (
        SELECT
            Company_Name,
            Industry,
            Last_Funding_Amount_USD_Millions,
            ROW_NUMBER() OVER (
                PARTITION BY
                    Industry
                ORDER BY
                    Last_Funding_Amount_USD_Millions DESC
            ) AS rn
        FROM startups
        WHERE
            Last_Funding_Amount_USD_Millions IS NOT NULL
    )
SELECT
    Industry,
    Company_Name,
    Last_Funding_Amount_USD_Millions
FROM RankedStartups
WHERE
    rn <= 3
ORDER BY
    Industry,
    Last_Funding_Amount_USD_Millions DESC;

-- Q6. Find all startups where the market size (in billion USD) is more than 3 times their last funding amount (in million USD).

SELECT
    Company_Name,
    Industry,
    Market_Size_Billion_USD,
    Last_Funding_Amount_USD_Millions
FROM startups
WHERE
    Market_Size_Billion_USD IS NOT NULL
    AND Last_Funding_Amount_USD_Millions IS NOT NULL
    AND Market_Size_Billion_USD * 1000 > 3 * Last_Funding_Amount_USD_Millions;
-- convert to millions

-- Q7. Count how many unique core technologies are being used by startups in the "FinTech" industry.

SELECT COUNT(DISTINCT Core_Technology) AS unique_core_tech
FROM startups
WHERE
    Industry = 'FinTech';

-- Q8. Find the most common core technology used in each industry
WITH TechCount AS (
    SELECT 
        Industry,
        Core_Technology,
        COUNT(*) AS Tech_Usage_Count,
        ROW_NUMBER() OVER (
            PARTITION BY Industry 
            ORDER BY COUNT(*) DESC
        ) AS rn
    FROM 
        Startups
    WHERE 
        Core_Technology IS NOT NULL
    GROUP BY 
        Industry, Core_Technology
)
SELECT 
    Industry,
    Core_Technology AS Most_Common_Tech,
    Tech_Usage_Count
FROM 
    TechCount
WHERE 
    rn = 1
ORDER BY 
    Tech_Usage_Count DESC;

-- Q9. For each year between 2010 and 2020, calculate the cumulative total funding received by all startups founded in that year.

WITH
    YearlyFunding AS (
        SELECT Founding_Year, SUM(
                Last_Funding_Amount_USD_Millions
            ) AS Total_Funding
        FROM startups
        WHERE
            Founding_Year BETWEEN 2010 AND 2020
        GROUP BY
            Founding_Year
    )
SELECT
    Founding_Year,
    Total_Funding,
    SUM(Total_Funding) OVER (
        ORDER BY
            Founding_Year ROWS BETWEEN UNBOUNDED PRECEDING
            AND CURRENT ROW
    ) AS cumulative_funding
FROM YearlyFunding;

-- Q10. Rank startups within each industry based on their last funding amount

SELECT 
    Industry,
    Company_Name,
    Last_Funding_Amount_USD_Millions,
    RANK() OVER (
        PARTITION BY Industry 
        ORDER BY Last_Funding_Amount_USD_Millions DESC
    ) AS Funding_Rank
FROM 
    Startups
WHERE 
    Last_Funding_Amount_USD_Millions IS NOT NULL
ORDER BY 
    Industry,
    Funding_Rank;


-- Q11. Find the CEOs who lead more than one startup and list all their associated company names.

SELECT CEO_Name, COUNT(*) AS Startup_Count
FROM startups
GROUP BY
    CEO_Name;

