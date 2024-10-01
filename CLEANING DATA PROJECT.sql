-- Data Cleaning

Select *
From layoffs;


-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. Null Values or blank Values
-- 4. Remove Any Colums or Rows


CREATE TABLE layoffs_staging
LIKE layoffs;


Select *
From layoffs_staging;

INSERT layoffs_staging
Select *
From layoffs;



Select *,
ROW_NUMBER () OVER (
PARTITION BY company, industry, total_laid_off, percentage_laid_off, 'date' ) AS row_num
From layoffs_staging;

With duplicate_CTE AS 

(
Select *,
ROW_NUMBER () OVER (
PARTITION BY 
company,
location,
industry,
total_laid_off,
percentage_laid_off,
'date',
stage, 
country,
funds_raised_millions) AS row_num
From layoffs_staging
)


Select * 
From duplicate_CTE
WHERE row_num > 1;


CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` text,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` INT DEFAULT NULL,
  `row_num` INT
   
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


Select *
From layoffs_staging2;


INSERT INTO layoffs_staging2

Select *,
ROW_NUMBER () OVER (
PARTITION BY 
company, 
location, 
industry, 
total_laid_off, 
percentage_laid_off,
'date',
stage, 
country,
funds_raised_millions) AS row_num
From layoffs_staging;

DELETE FROM layoffs_staging2
WHERE row_num > 1;

Select *
FROM layoffs_staging2;

-- Standardizing Data

SELECT company, trim(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = trim(company);

SELECT DISTINCT industry
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET industry = 'Crypto'
Where industry LIKE 'Crypto%';

SELECT DISTINCT country, trim(TRAILING '.' FROM country)
FROM layoffs_staging2
Order by 1;

UPDATE layoffs_staging2
SET country = trim(TRAILING '.' FROM country)
Where country LIKE 'United States%';

SELECT `date`,
STR_TO_DATE(`date`, '%Y-%m-%d')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%Y-%m-%d');

ALTER TABLE layoffs_staging2
Modify Column `date` DATE;

Select *
From layoffs_staging2
WHERE total_laid_off is NULL
AND percentage_laid_off IS NULL;

DELETE
From layoffs_staging2
WHERE total_laid_off is NULL
AND percentage_laid_off IS NULL;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;


UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';


SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';


SELECT *
FROM layoffs_staging2
WHERE company LIKE 'Bally%';

SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
    AND t1.location = t2.location
WHERE(t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL;

SELECT *
FROM layoffs_staging2;


