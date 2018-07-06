DELETE FROM @target_cohort_table
WHERE (subject_id, cohort_start_date) IN (

	SELECT c.subject_id, MAX(cohort_start_date)  FROM 
		(SELECT b.subject_id FROM (
			SELECT subject_id, COUNT(subject_id) as count FROM
			@target_database_schema.@target_cohort_table WHERE cohort_definition_id=2 or cohort_definition_id=3
			GROUP BY subject_id ) b
		WHERE b.count >1 
		) c INNER JOIN @target_database_schema.@target_cohort_table ON (c.subject_id = @target_cohort_table.subject_id)
			WHERE @target_cohort_table.cohort_definition_id=2 or @target_cohort_table.cohort_definition_id=3
	GROUP BY c.subject_id
	)

