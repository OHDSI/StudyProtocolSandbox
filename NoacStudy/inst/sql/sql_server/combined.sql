DELETE FROM @target_database_schema.@target_cohort_table where cohort_definition_id = @cohort_definition_id;

INSERT INTO @target_database_schema.@target_cohort_table (cohort_definition_id, subject_id, cohort_start_date, cohort_end_date)
SELECT @cohort_definition_id AS cohort_definition_id, subject_id, cohort_start_date, cohort_end_date
FROM @target_database_schema.@target_cohort_table 
WHERE cohort_definition_id IN (10, 11, 15,16, 17);