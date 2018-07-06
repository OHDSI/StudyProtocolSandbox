SELECT 'Gender, Unknown', COUNT(c.gender_concept_id), Null, Null, Null, Null, Null, Null, Null FROM (
	SELECT DISTINCT ON (b.subject_id) b.subject_id, b.gender_concept_id FROM 
		(SELECT subject_id, gender_concept_id FROM 
			(
			SELECT * FROM @target_database_schema.@target_cohort_table LEFT JOIN @cdm_database_schema.person ON (@target_cohort_table.subject_id = person.person_id)
			) a WHERE cohort_definition_id=0
		GROUP BY subject_id, gender_concept_id) b
	) c WHERE c.gender_concept_id = 8551



