
SELECT 'LDL Cholesterol', Null, MIN(c.indiv_mean), percentile_disc(0.25) WITHIN GROUP (ORDER BY c.indiv_mean), MEDIAN(c.indiv_mean), percentile_disc(0.75) WITHIN GROUP (ORDER BY c.indiv_mean), 
MAX(c.indiv_mean), AVG(c.indiv_mean), STDDEV(c.indiv_mean) FROM (
	SELECT b.person_id, AVG(b.value_as_number) AS indiv_mean FROM
		(SELECT * FROM 
			(SELECT * FROM @target_database_schema.@target_cohort_table LEFT JOIN @cdm_database_schema.measurement ON (@target_cohort_table.subject_id = measurement.person_id) 
			WHERE @target_cohort_table.cohort_definition_id=0) a 
		WHERE DATE_PART('year', a.cohort_start_date) - DATE_PART('year', a.measurement_date) <=1 ) b	 
	WHERE b.measurement_concept_id = 3035899   GROUP BY b.person_id ) c 
