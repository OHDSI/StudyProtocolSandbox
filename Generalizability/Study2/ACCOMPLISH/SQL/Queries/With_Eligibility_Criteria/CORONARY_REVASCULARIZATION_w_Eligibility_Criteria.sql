SELECT 'Coronary Revascularization', COUNT(*), Null, Null, Null, Null, Null, Null, Null FROM (
	SELECT DISTINCT c.person_id FROM
		(SELECT * FROM
			(SELECT A.person_id, A.cohort_start_date, A.procedure_date, A.procedure_concept_id, concept_ancestor.ancestor_concept_id, concept_ancestor.descendant_concept_id FROM
				(SELECT * FROM @target_database_schema.@target_cohort_table LEFT JOIN @cdm_database_schema.procedure_occurrence ON (@target_cohort_table.subject_id = procedure_occurrence.person_id)) A
			LEFT JOIN @cdm_database_schema.concept_ancestor ON (procedure_concept_id=concept_ancestor.descendant_concept_id) WHERE cohort_definition_id=2 or cohort_definition_id=3) b
		WHERE b.procedure_date <= b.cohort_start_date
		)c
	WHERE c.ancestor_concept_id = 4336464 or c.ancestor_concept_id = 4184832 or c.ancestor_concept_id = 4304209 ) d

