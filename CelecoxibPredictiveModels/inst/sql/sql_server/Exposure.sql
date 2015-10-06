/* 	Manually created cohort definition: first use of celecoxib requiring 183 days of observation prior to start.
	Cohort end date is 365 days after cohort start date or end of observation period, whichever is earliest.	*/
DELETE
FROM @target_database_schema.@target_cohort_table
WHERE cohort_definition_id = @cohort_definition_id;

INSERT INTO @target_database_schema.@target_cohort_table (
	cohort_definition_id,
	subject_id,
	cohort_start_date,
	cohort_end_date
	)
SELECT @cohort_definition_id,
	first_exposure.person_id AS subject_id,
	start_date AS cohort_start_date,
	CASE 
		WHEN DATEADD(DAY, 365, start_date) > observation_period_end_date
			THEN observation_period_end_date
		ELSE DATEADD(DAY, 365, start_date)
		END AS cohort_end_date
FROM (
	SELECT person_id,
		MIN(drug_era_start_date) AS start_date
	FROM @cdm_database_schema.drug_era
	WHERE drug_concept_id = 1118084
	GROUP BY person_id
	) first_exposure
INNER JOIN @cdm_database_schema.observation_period
	ON first_exposure.person_id = observation_period.person_id
WHERE DATEDIFF(DAY, observation_period_start_date, start_date) >= 183;
