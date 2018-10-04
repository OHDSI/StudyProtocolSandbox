DELETE FROM @target_database_schema.@target_cohort_table where cohort_definition_id = @target_cohort_id;

INSERT INTO @target_database_schema.@target_cohort_table (cohort_definition_id, subject_id, cohort_start_date, cohort_end_date)

SELECT DISTINCT @target_cohort_id as cohort_definition_id, VISIT_OCCURRENCE.person_id as subject_id, visit_end_date as cohort_start_date , visit_end_date as cohort_end_date 
FROM @cdm_database_schema.VISIT_OCCURRENCE
JOIN @cdm_database_schema.NOTE 
	ON VISIT_OCCURRENCE.visit_end_date = NOTE.note_date
where visit_concept_id in (select descendant_concept_id from @cdm_database_schema.concept_ancestor where ancestor_concept_id in (9201,9203, 262))
and datediff(day,visit_start_date, visit_end_date)>=7 AND VISIT_START_DATE >= '2005-01-01';


