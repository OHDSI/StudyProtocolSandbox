IF object_id('@target_database_schema.@target_cohort_definition_table', 'U') is null
BEGIN 
	CREATE TABLE @target_database_schema.@target_cohort_definition_table ( 
		cohort_definition_id int NOT NULL,
		cohort_definition_name varchar(255) NOT NULL,
		cohort_type int NULL    --0-exposure, 1-outcome of interest, 2-negative control
	)
END
;




IF object_id('@target_database_schema.@target_cohort_table', 'U') is null
BEGIN 
	CREATE TABLE @target_database_schema.@target_cohort_table ( 
		cohort_definition_id int NOT NULL,
		subject_id bigint NOT NULL,
		cohort_start_date date,
		cohort_end_date date
	)
END
;