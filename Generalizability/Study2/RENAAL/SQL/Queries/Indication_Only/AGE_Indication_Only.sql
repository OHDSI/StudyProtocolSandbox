
SELECT 'Age', Null, MIN(age), percentile_disc(0.25) WITHIN GROUP (ORDER BY age), percentile_disc(0.5) WITHIN GROUP (ORDER BY age), percentile_disc(0.75) WITHIN GROUP (ORDER BY age), 
MAX(age), AVG(age), STDDEV(age) FROM (
	SELECT a.cohort_start_date, a.birth_date, DATE_PART('year', a.cohort_start_date) - DATE_PART('year', a.birth_date) AS age FROM
		(SELECT b.cohort_start_date, TO_DATE(TO_CHAR(b.year_of_birth,'9999') || TO_CHAR(b.month_of_birth,'00') || TO_CHAR(b.day_of_birth, '00'), 'YYYYMMDD') AS birth_date 
		FROM
			(SELECT * FROM @target_database_schema.@target_cohort_table LEFT JOIN @cdm_database_schema.person ON (@target_cohort_table.subject_id = person.person_id)
			WHERE year_of_birth != 1776 AND cohort_definition_id=1) b
		) AS a
	) c;


