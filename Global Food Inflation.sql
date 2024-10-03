-- Select  data from the GlobalInflation table
SELECT 
    Country, 
    Inflation, 
    High, 
    Low, 
    [Open], 
    [Close],
    Date 
FROM
    PortfolioProject..GlobalInflation
WHERE
    Inflation IS NOT NULL
    AND Date LIKE '%202%';

-- Monthly Inflation Calculation
;WITH MonthlyInflation AS (
    SELECT 
        Country,
        Date,
        [Close],
        LAG([Close]) OVER (PARTITION BY Country ORDER BY Date) AS Prev_Close
    FROM 
        PortfolioProject..GlobalInflation
)
SELECT 
    Country,
    Date,
    [Close],
    Prev_Close,
    CASE 
        WHEN Prev_Close IS NOT NULL THEN 
            ([Close] - Prev_Close) / Prev_Close * 100
        ELSE 
            NULL
    END AS Inflation_Rate
FROM 
    MonthlyInflation
WHERE 
    Date LIKE '%202%'
ORDER BY 
    Date;

-- Total Inflation per Year Calculation
;WITH YearlyInflation AS (
    SELECT 
        Country,
        YEAR(Date) AS Year,
        [Close],
        LAG([Close]) OVER (PARTITION BY Country ORDER BY Date) AS Prev_Close
    FROM 
        PortfolioProject..GlobalInflation
)
SELECT 
    Country,
    Year,
    SUM(CASE 
        WHEN Prev_Close IS NOT NULL THEN 
            ([Close] - Prev_Close) / Prev_Close * 100
        ELSE 
            0
    END) AS Total_Inflation
FROM 
    YearlyInflation
WHERE 
    Year LIKE '%202%'
GROUP BY 
    Country, Year
ORDER BY 
    Country, Year;

-- Top 10 Countries with Highest Total Inflation
;WITH TopCountries AS (
    SELECT 
        Country,
        YEAR(Date) AS Year,
        [Close],
        LAG([Close]) OVER (PARTITION BY Country ORDER BY Date) AS Prev_Close
    FROM 
        PortfolioProject..GlobalInflation
),
YearlyInflation AS (
    SELECT 
        Country,
        SUM(CASE 
            WHEN Prev_Close IS NOT NULL THEN 
                ([Close] - Prev_Close) / Prev_Close * 100
            ELSE 
                0
        END) AS Total_Inflation
    FROM 
        TopCountries
    GROUP BY 
        Country
)
SELECT TOP 10
    Country,
    Total_Inflation
FROM 
    YearlyInflation
ORDER BY 
    Total_Inflation DESC;

-- Top 10 Countries with Lowest Total Inflation
;WITH TopCountries AS (
    SELECT 
        Country,
        YEAR(Date) AS Year,
        [Close],
        LAG([Close]) OVER (PARTITION BY Country ORDER BY Date) AS Prev_Close
    FROM 
        PortfolioProject..GlobalInflation
),
YearlyInflation AS (
    SELECT 
        Country,
        SUM(CASE 
            WHEN Prev_Close IS NOT NULL THEN 
                ([Close] - Prev_Close) / Prev_Close * 100
            ELSE 
                0
        END) AS Total_Inflation
    FROM 
        TopCountries
    GROUP BY 
        Country
)
SELECT TOP 10
    Country,
    Total_Inflation
FROM 
    YearlyInflation
ORDER BY 
    Total_Inflation ASC;


