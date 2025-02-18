-- Step 1  - not applicable but note this was all done in SQLite.

-- Step 2. Counting number of rows with NULL for the ethnicity column.
-- Nice reminder of how much eaiser this is in pandas!
SELECT SUM(CASE WHEN ETHNICITY = '' THEN 1 ELSE 0 END) AS ethnicity_null_count
FROM patients
;

-- Step 3:
SELECT
VITALSTATUSDATE
, SUBSTRING(VITALSTATUSDATE, 0, 5) AS VitalStatusDate_Year -- No date types in SQLite!
FROM patients
;

-- Step 4:
SELECT 
p.GENDER 
, t.age
, COUNT(DISTINCT p.PATIENTID)
FROM patients as p
	INNER JOIN tumours as t 
	on p.PATIENTID = t.PATIENTID
GROUP BY p.GENDER, t.age
;

-- Step 5:
WITH base_aggregation AS 
(
SELECT 
P.PATIENTID 
, COUNT(T.TUMOURID) AS tumour_count
FROM patients as p
	INNER JOIN tumours as t 
	on p.PATIENTID = t.PATIENTID
GROUP BY p.PATIENTID
)
SELECT 
tumour_count
, COUNT(DISTINCT PATIENTID) AS patient_count
FROM base_aggregation
GROUP BY tumour_count 
ORDER BY patient_count DESC
;

-- Step 6:

-- a)
SELECT 
ETHNICITY
, COUNT(DISTINCT p.PATIENTID) AS patient_count
, COUNT(DISTINCT p.PATIENTID) * 100 / SUM(COUNT(DISTINCT p.PATIENTID)) OVER () AS percentage_of_total
FROM patients as p
	INNER JOIN tumours as t 
	on p.PATIENTID = t.PATIENTID
WHERE t.QUINTILE_2019 = '1 - most deprived'
AND ETHNICITY != ''
GROUP BY ETHNICITY
ORDER BY patient_count DESC
LIMIT 5
;

-- b)
SELECT 
ETHNICITY
, COUNT(DISTINCT CASE WHEN t.QUINTILE_2019 = '1 - most deprived' THEN p.PATIENTID END) AS low_income_earners
, COUNT(DISTINCT p.PATIENTID) AS TOTAL_PATIENTS
, COUNT(DISTINCT CASE WHEN t.QUINTILE_2019 = '1 - most deprived' THEN p.PATIENTID END) * 100 / 
	COUNT(DISTINCT p.PATIENTID) AS PROPORTION_OF_TOTAL_PATIENTS
FROM patients as p
	INNER JOIN tumours as t 
	on p.PATIENTID = t.PATIENTID
WHERE ETHNICITY != ''
GROUP BY ETHNICITY
ORDER BY PROPORTION_OF_TOTAL_PATIENTS DESC
LIMIT 5
;
