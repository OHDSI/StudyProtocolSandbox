
SELECT 'Myocardial Infarction', COUNT(*), Null, Null, Null, Null, Null, Null, Null FROM (
	SELECT DISTINCT c.person_id FROM
		(SELECT * FROM
			(SELECT A.person_id, A.cohort_start_date, A.condition_start_date, A.condition_concept_id, concept_ancestor.ancestor_concept_id, concept_ancestor.descendant_concept_id FROM
				(SELECT * FROM @target_database_schema.@target_cohort_table LEFT JOIN @cdm_database_schema.condition_occurrence ON (@target_cohort_table.subject_id = condition_occurrence.person_id)) A
			LEFT JOIN @cdm_database_schema.concept_ancestor ON (condition_concept_id=concept_ancestor.descendant_concept_id) WHERE cohort_definition_id=1) b
		WHERE b.condition_start_date <= b.cohort_start_date
		)c
	WHERE c.ancestor_concept_id = 314666 OR c.ancestor_concept_id = 312327 ) d 

