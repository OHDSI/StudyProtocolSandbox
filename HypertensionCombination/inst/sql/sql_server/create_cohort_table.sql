CREATE TABLE @target_database_schema.@cohort_table (
  cohort_definition_id int NOT NULL,
  subject_id int NOT NULL,
  cohort_start_date date NOT NULL,
  cohort_end_date date
)
;