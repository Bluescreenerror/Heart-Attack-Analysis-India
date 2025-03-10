-- Using the database

use heartattackdb;

-- Selecting all the rows to check the data

SELECT * FROM heartattack;

-- Looking at the Smoking, Alcohol, Obesity, Hypertension, Diabetes and Physical Activity numbers

SELECT State_Name, SUM(Smoking) as Smoking, SUM(Alcohol_consumption) as Alcohol, SUM(Obesity) as Obesity, 
SUM(Hypertension) as Hypertension, SUM(Diabetes) as Diabetes, SUM(Physical_Activity) as Activity 
FROM heartAttack 
GROUP BY State_Name 
ORDER BY 2,7;

-- Comparing the impact of each habit on heart attack rates (independent analysis) (PIE-CHART)

SELECT 
	COUNT(*) AS patientsWhoSufferedHA,
	SUM(Smoking) AS smokersWhoSufferedHA,
	SUM(Alcohol_Consumption) AS drinkersWhoSufferedHA,
	SUM(Diabetes) AS diabeticsWhoSufferedHA,
	SUM(Hypertension) AS hypertensiveWhoSufferedHA,
	SUM(Obesity) AS obeseWhoSufferedHA
	FROM heartAttack
	WHERE Heart_Attack_History = 1;

-- Comparing the impact of each habit on heart attack rates (isolated analysis) (PIE-CHART)

SELECT 
    COUNT(*) AS patientsWhoSufferedHA, 
    SUM(CASE WHEN Smoking = 1 AND Alcohol_Consumption = 0 AND Diabetes = 0 AND Hypertension = 0 AND Obesity = 0 THEN 1 ELSE 0 END) AS smokersWhoSufferedHA,
    SUM(CASE WHEN Alcohol_Consumption = 1 AND Smoking = 0 AND Diabetes = 0 AND Hypertension = 0 AND Obesity = 0 THEN 1 ELSE 0 END) AS drinkersWhoSufferedHA,
    SUM(CASE WHEN Diabetes = 1 AND Smoking = 0 AND Alcohol_Consumption = 0 AND Hypertension = 0 AND Obesity = 0 THEN 1 ELSE 0 END) AS diabeticsWhoSufferedHA,
    SUM(CASE WHEN Hypertension = 1 AND Smoking = 0 AND Alcohol_Consumption = 0 AND Diabetes = 0 AND Obesity = 0 THEN 1 ELSE 0 END) AS hypertensiveWhoSufferedHA,
	SUM(CASE WHEN Obesity = 1 AND Smoking = 0 AND Alcohol_Consumption = 0 AND Diabetes = 0 AND Hypertension = 0 THEN 1 ELSE 0 END) AS obeseWhoSufferedHA
FROM heartAttack
WHERE Heart_Attack_History = 1;

-- Looking at the percent of patients smoking and drinking from each state

SELECT 
    State_Name, 
    COUNT(*) AS totalPatients, 
    SUM(Smoking) AS totalSmokers, 
    SUM(Alcohol_Consumption) AS totalDrinkers, 
    CAST(SUM(Smoking) AS FLOAT) / COUNT(*) * 100 AS smokerPercent, 
    CAST(SUM(Alcohol_Consumption) AS FLOAT) / COUNT(*) * 100 AS drinkerPercent
FROM heartAttack
GROUP BY State_Name
ORDER BY totalPatients DESC; 

-- Looking at the heart attack percent for each state (GEOSPATIAL)

SELECT 
	State_Name, 
    COUNT(*) AS totalPatients, 
	SUM(Heart_Attack_History) as heartAttackPatients,
	(SUM(Heart_Attack_History)/COUNT(*)) * 100 as percentOfHeartAttack
FROM heartAttack 
GROUP BY State_Name
ORDER BY percentOfHeartAttack desc;	

-- Looking at the % of heart attacks by age (STACKED CHART)

SELECT 
    CASE 
        WHEN Age BETWEEN 20 AND 29 THEN '20-29'
        WHEN Age BETWEEN 30 AND 39 THEN '30-39'
        WHEN Age BETWEEN 40 AND 49 THEN '40-49'
        WHEN Age BETWEEN 50 AND 59 THEN '50-59'
        WHEN Age BETWEEN 60 AND 69 THEN '60-69'
        WHEN Age BETWEEN 70 AND 79 THEN '70-79'
        ELSE '80+'
    END AS ageGroup,
	COUNT(*) AS totalPatients,
    SUM(Heart_Attack_History) AS patientsWhoSufferedHA,
    (SUM(Heart_Attack_History) / COUNT(*)) * 100 AS percentOfHA
	FROM heartAttack
GROUP BY 
    CASE 
        WHEN Age BETWEEN 20 AND 29 THEN '20-29'
        WHEN Age BETWEEN 30 AND 39 THEN '30-39'
        WHEN Age BETWEEN 40 AND 49 THEN '40-49'
        WHEN Age BETWEEN 50 AND 59 THEN '50-59'
        WHEN Age BETWEEN 60 AND 69 THEN '60-69'
        WHEN Age BETWEEN 70 AND 79 THEN '70-79'
        ELSE '80+'
    END
ORDER BY ageGroup;

-- Looking at the relation between smoking, drinking and heart attacks

-- % of smokers who suffered heart attack (prevalenceRate) by state 

SELECT 
	State_Name, 
    COUNT(*) AS smokers,
	SUM(Heart_Attack_History) as smokersWhoSufferedHA,
	(SUM(Heart_Attack_History)/COUNT(*)) * 100 as prevalencerate
FROM heartAttack 
WHERE Smoking = 1
GROUP BY State_Name
ORDER BY smokers desc;	

-- % of smokers who suffered heart attack (prevalenceRate) by age with the general population (STACKED CHART)

WITH age_grouped AS (
    SELECT 
        CASE 
            WHEN Age BETWEEN 20 AND 29 THEN '20-29'
            WHEN Age BETWEEN 30 AND 39 THEN '30-39'
            WHEN Age BETWEEN 40 AND 49 THEN '40-49'
            WHEN Age BETWEEN 50 AND 59 THEN '50-59'
            WHEN Age BETWEEN 60 AND 69 THEN '60-69'
            WHEN Age BETWEEN 70 AND 79 THEN '70-79'
            ELSE '80+'
        END AS ageGroup,
        Smoking,
        Heart_Attack_History
    FROM heartAttack
)

SELECT 
    a.ageGroup,
    COUNT(*) AS totalSmokers,
    SUM(a.Heart_Attack_History) AS smokersWhoSufferedHA,
    (SUM(a.Heart_Attack_History) * 100.0 / COUNT(*)) AS smokerPrevalenceRate,
    totalHA.totalPatientsWhoSufferedHA,
    totalHA.percentOfHAInGeneralPop
FROM age_grouped a
JOIN (
    SELECT 
        CASE 
            WHEN Age BETWEEN 20 AND 29 THEN '20-29'
            WHEN Age BETWEEN 30 AND 39 THEN '30-39'
            WHEN Age BETWEEN 40 AND 49 THEN '40-49'
            WHEN Age BETWEEN 50 AND 59 THEN '50-59'
            WHEN Age BETWEEN 60 AND 69 THEN '60-69'
            WHEN Age BETWEEN 70 AND 79 THEN '70-79'
            ELSE '80+'
        END AS ageGroup,
        SUM(Heart_Attack_History) AS totalPatientsWhoSufferedHA,
        (SUM(Heart_Attack_History) * 100.0 / COUNT(*)) AS percentOfHAInGeneralPop
    FROM heartAttack
    GROUP BY 
        CASE 
            WHEN Age BETWEEN 20 AND 29 THEN '20-29'
            WHEN Age BETWEEN 30 AND 39 THEN '30-39'
            WHEN Age BETWEEN 40 AND 49 THEN '40-49'
            WHEN Age BETWEEN 50 AND 59 THEN '50-59'
            WHEN Age BETWEEN 60 AND 69 THEN '60-69'
            WHEN Age BETWEEN 70 AND 79 THEN '70-79'
            ELSE '80+'
        END 
) AS totalHA ON a.ageGroup = totalHA.ageGroup
WHERE a.Smoking = 1
GROUP BY a.ageGroup, totalHA.totalPatientsWhoSufferedHA, totalHA.percentOfHAInGeneralPop
ORDER BY a.ageGroup;

-- % of drinkers who suffered heart attack (prevalenceRate) by state

SELECT 
	State_Name, 
    COUNT(*) AS drinkers,
	SUM(Heart_Attack_History) as drinkersWhoSufferedHA,
	(SUM(Heart_Attack_History)/COUNT(*)) * 100 as prevalenceRate
FROM heartAttack 
WHERE Alcohol_Consumption = 1
GROUP BY State_Name
ORDER BY drinkers desc;	

-- % of drinkers who suffered heart attack (prevalenceRate) by age compared with the general population (STACKED CHART)

WITH age_grouped AS (
    SELECT 
        CASE 
            WHEN Age BETWEEN 20 AND 29 THEN '20-29'
            WHEN Age BETWEEN 30 AND 39 THEN '30-39'
            WHEN Age BETWEEN 40 AND 49 THEN '40-49'
            WHEN Age BETWEEN 50 AND 59 THEN '50-59'
            WHEN Age BETWEEN 60 AND 69 THEN '60-69'
            WHEN Age BETWEEN 70 AND 79 THEN '70-79'
            ELSE '80+'
        END AS ageGroup,
        Alcohol_Consumption,
        Heart_Attack_History
    FROM heartAttack
)

SELECT 
    a.ageGroup,
    COUNT(*) AS totalDrinkers,
    SUM(a.Heart_Attack_History) AS drinkersWhoSufferedHA,
    (SUM(a.Heart_Attack_History) * 100.0 / COUNT(*)) AS drinkerPrevalenceRate,
    totalHA.totalPatientsWhoSufferedHA,
    totalHA.percentOfHAInGeneralPop
FROM age_grouped a
JOIN (
    SELECT 
        CASE 
            WHEN Age BETWEEN 20 AND 29 THEN '20-29'
            WHEN Age BETWEEN 30 AND 39 THEN '30-39'
            WHEN Age BETWEEN 40 AND 49 THEN '40-49'
            WHEN Age BETWEEN 50 AND 59 THEN '50-59'
            WHEN Age BETWEEN 60 AND 69 THEN '60-69'
            WHEN Age BETWEEN 70 AND 79 THEN '70-79'
            ELSE '80+'
        END AS ageGroup,
        SUM(Heart_Attack_History) AS totalPatientsWhoSufferedHA,
        (SUM(Heart_Attack_History) * 100.0 / COUNT(*)) AS percentOfHAInGeneralPop
    FROM heartAttack
    GROUP BY 
        CASE 
            WHEN Age BETWEEN 20 AND 29 THEN '20-29'
            WHEN Age BETWEEN 30 AND 39 THEN '30-39'
            WHEN Age BETWEEN 40 AND 49 THEN '40-49'
            WHEN Age BETWEEN 50 AND 59 THEN '50-59'
            WHEN Age BETWEEN 60 AND 69 THEN '60-69'
            WHEN Age BETWEEN 70 AND 79 THEN '70-79'
            ELSE '80+'
        END 
) AS totalHA ON a.ageGroup = totalHA.ageGroup
WHERE a.Alcohol_Consumption = 1
GROUP BY a.ageGroup, totalHA.totalPatientsWhoSufferedHA, totalHA.percentOfHAInGeneralPop
ORDER BY a.ageGroup;

-- % of total heart attacks cases that were smokers by state

SELECT 
    ha1.State_Name, 
    COUNT(*) AS smokers,
	totalCases,
    SUM(ha1.Heart_Attack_History) AS smokersWhoSufferedHA,
    (SUM(ha1.Heart_Attack_History) / totalHA.totalCases) * 100 AS percentOfHeartAttackCases
FROM heartAttack ha1
JOIN (
    SELECT State_Name, SUM(Heart_Attack_History) AS totalCases 
    FROM heartAttack 
    GROUP BY State_Name
) AS totalHA
ON ha1.State_Name = totalHA.State_Name
WHERE ha1.Smoking = 1
GROUP BY ha1.State_Name, totalHA.totalCases
ORDER BY smokers DESC;

-- % of total heart attacks cases that were drinkers by state

SELECT 
    ha1.State_Name, 
    COUNT(*) AS drinkers,
	totalCases,
    SUM(ha1.Heart_Attack_History) AS drinkersWhoSufferedHA,
    (SUM(ha1.Heart_Attack_History) / totalHA.totalCases) * 100 AS percentOfHeartAttackCases
FROM heartAttack ha1
JOIN (
    SELECT State_Name, SUM(Heart_Attack_History) AS totalCases 
    FROM heartAttack 
    GROUP BY State_Name
) AS totalHA
ON ha1.State_Name = totalHA.State_Name
WHERE ha1.Alcohol_Consumption = 1
GROUP BY ha1.State_Name, totalHA.totalCases
ORDER BY drinkers DESC;

-- % of total heart attacks cases that were smokers and drinkers by age

WITH age_grouped AS (
    SELECT 
        CASE 
            WHEN Age BETWEEN 20 AND 29 THEN '20-29'
            WHEN Age BETWEEN 30 AND 39 THEN '30-39'
            WHEN Age BETWEEN 40 AND 49 THEN '40-49'
            WHEN Age BETWEEN 50 AND 59 THEN '50-59'
            WHEN Age BETWEEN 60 AND 69 THEN '60-69'
            WHEN Age BETWEEN 70 AND 79 THEN '70-79'
            ELSE '80+'
        END AS ageGroup,
        Alcohol_Consumption,
        Heart_Attack_History
    FROM heartAttack
)

SELECT 
    a.ageGroup,
    COUNT(*) AS totalDrinkers,
    SUM(a.Heart_Attack_History) AS drinkersWhoSufferedHA,
    (SUM(a.Heart_Attack_History) * 100.0 / COUNT(*)) AS drinkerFatalityRate,
    totalHA.totalPatientsWhoSufferedHA,
    totalHA.percentOfHAInGeneralPop
FROM age_grouped a
JOIN (
    SELECT 
        CASE 
            WHEN Age BETWEEN 20 AND 29 THEN '20-29'
            WHEN Age BETWEEN 30 AND 39 THEN '30-39'
            WHEN Age BETWEEN 40 AND 49 THEN '40-49'
            WHEN Age BETWEEN 50 AND 59 THEN '50-59'
            WHEN Age BETWEEN 60 AND 69 THEN '60-69'
            WHEN Age BETWEEN 70 AND 79 THEN '70-79'
            ELSE '80+'
        END AS ageGroup,
        SUM(Heart_Attack_History) AS totalPatientsWhoSufferedHA,
        (SUM(Heart_Attack_History) * 100.0 / COUNT(*)) AS percentOfHAInGeneralPop
    FROM heartAttack
    GROUP BY 
        CASE 
            WHEN Age BETWEEN 20 AND 29 THEN '20-29'
            WHEN Age BETWEEN 30 AND 39 THEN '30-39'
            WHEN Age BETWEEN 40 AND 49 THEN '40-49'
            WHEN Age BETWEEN 50 AND 59 THEN '50-59'
            WHEN Age BETWEEN 60 AND 69 THEN '60-69'
            WHEN Age BETWEEN 70 AND 79 THEN '70-79'
            ELSE '80+'
        END 
) AS totalHA ON a.ageGroup = totalHA.ageGroup
WHERE a.Alcohol_Consumption = 1
GROUP BY a.ageGroup, totalHA.totalPatientsWhoSufferedHA, totalHA.percentOfHAInGeneralPop
ORDER BY a.ageGroup;
