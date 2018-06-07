delete from @cohort_database_schema.@cohort_table
where cohort_definition_id = 59870
;

insert into @cohort_database_schema.@cohort_table
(
	cohort_definition_id,
	subject_id,
	cohort_start_date,
	cohort_end_date
)
select
  59870 as cohort_definition_id
  , subject_id
  , dateadd(year, -1, cohort_start_date) as cohort_start_date
  , dateadd(year, 1, cohort_start_date) as cohort_end_date
from @cohort_database_schema.@cohort_table
where cohort_definition_id = 5987
;
