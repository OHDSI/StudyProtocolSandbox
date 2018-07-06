SELECT 'Age GTE 70', COUNT(d.subject_id), Null, Null, Null, Null, Null, Null, Null FROM (

	SELECT a.subject_id, a.cohort_start_date, a.birth_date, DATE_PART('year', a.cohort_start_date) - DATE_PART('year', a.birth_date) AS age FROM
		(SELECT b. subject_id, b.cohort_start_date, TO_DATE(TO_CHAR(b.year_of_birth,'9999') || TO_CHAR(b.month_of_birth,'00') || TO_CHAR(b.day_of_birth, '00'), 'YYYYMMDD') AS birth_date 
		FROM
			(SELECT * FROM @target_database_schema.@target_cohort_table LEFT JOIN @cdm_database_schema.person ON (@target_cohort_table.subject_id = person.person_id)
			WHERE year_of_birth != 1776 AND cohort_definition_id=2 or cohort_definition_id=3) b
		) a
		) d
WHERE d.age >= 70

