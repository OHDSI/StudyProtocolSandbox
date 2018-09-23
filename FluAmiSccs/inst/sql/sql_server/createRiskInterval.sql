delete from @cohort_database_schema.@cohort_table
where cohort_definition_id in (@new_ip_flu_cohort_ids)
;

insert into @cohort_database_schema.@cohort_table
(
	cohort_definition_id,
	subject_id,
	cohort_start_date,
	cohort_end_date
)
select
  cohort_definition_id * 100 as cohort_definition_id
  , subject_id
  , dateadd(dd, 1, cohort_end_date) as cohort_start_date
  , dateadd(dd, 7, cohort_start_date) as cohort_end_date
from @cohort_database_schema.@cohort_table
where datediff(dd, cohort_end_date, dateadd(dd, 7, cohort_start_date)) > 0
and cohort_definition_id in (@ip_flu_cohort_ids)
;
