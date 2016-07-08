IF OBJECT_ID('@cohort_database_schema.@cohort_table', 'U') IS NOT NULL
  DROP TABLE @cohort_database_schema.@cohort_table;
  
CREATE TABLE @cohort_database_schema.@cohort_table (
	subject_id BIGINT, 
{@cdm_version == '4'} ? {
	cohort_concept_id INT,
} : {
	cohort_definition_id INT,
}
	cohort_start_date DATE,
	cohort_end_date DATE
);
