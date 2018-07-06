USE CDM_Optum_Extended_SES_v733
USE CDM_Truven_CCAE_v750


DROP TABLE #TempTable;

--cohort ids: 7011 (cabergoline) and 7010 (bromocriptine)
--on drug time is the difference between the cohort end date and the cohort start date. 
--The off drug time is the difference between the observation period end date and the cohort end date.

SELECT db,
       cohort,
       subject_id,
       cohort_start_date,
       cohort_end_date,
       observation_period_start_date,
       observation_period_end_date,
       DATEDIFF(dd,cohort_start_date,cohort_end_date) AS ONDRUGDAYS,
       DATEDIFF(dd,cohort_end_date,observation_period_end_date) AS OFFDRUGDAYS INTO #TempTable
FROM CDM_Optum_Extended_SES_v733.ohdsi_results.cohort
  JOIN (SELECT 'OPTUM' AS db,
               'BROMO-7010' AS cohort,
               person_id AS op_person_id,
               observation_period_start_date,
               observation_period_end_date
        FROM CDM_Optum_Extended_SES_v733.dbo.observation_period) op
    ON subject_id = op.op_PERSON_ID
   AND cohort_definition_id = 7010
   AND cohort_start_date >= observation_period_start_date
   AND cohort_end_date <= observation_period_end_date
ORDER BY ONDRUGDAYS

SELECT AVG(ONDRUGDAYS),
       AVG(OFFDRUGDAYS)
FROM #TempTable


