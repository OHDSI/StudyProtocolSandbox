SELECT '1 Antihypertensive Drugs', COUNT(e.person_id), Null, Null, Null, Null, Null, Null, Null FROM (

	SELECT d.person_id, COUNT(d.AHT_class) as aht_count FROM (
		SELECT DISTINCT c.person_id, c.AHT_class FROM (
			SELECT b.person_id, b.drug_exposure_start_date, b.cohort_start_date,
				CASE
				WHEN b.ancestor_concept_id = '21600382' THEN 'C02A'
				WHEN b.ancestor_concept_id = '21600403' THEN 'C02B'
				WHEN b.ancestor_concept_id = '21600409' THEN 'C02C'
				WHEN b.ancestor_concept_id = '21600424' THEN 'C02D'
				WHEN b.ancestor_concept_id = '21600451' THEN 'C02L' 
				WHEN b.ancestor_concept_id = '21601460' THEN 'C02N'

				WHEN b.ancestor_concept_id = '21601462' THEN 'C03A'
				WHEN b.ancestor_concept_id = '21601489' THEN 'C03B/C'
				WHEN b.ancestor_concept_id = '21601516' THEN 'C03B/C'
				WHEN b.ancestor_concept_id = '21601532' THEN 'C03D'

				WHEN b.ancestor_concept_id = '21601561' THEN 'C04A'

				WHEN b.ancestor_concept_id = '21601665' THEN 'C07A'

				WHEN b.ancestor_concept_id = '21601745' THEN 'C08C/D/E'
				WHEN b.ancestor_concept_id = '21601765' THEN 'C08C/D/E'
				WHEN b.ancestor_concept_id = '21601772' THEN 'C08C/D/E'

				WHEN b.ancestor_concept_id = '21601783' THEN 'C09A/B/C/D/X'
				WHEN b.ancestor_concept_id = '21601801' THEN 'C09A/B/C/D/X'
				WHEN b.ancestor_concept_id = '21601822' THEN 'C09A/B/C/D/X'
				WHEN b.ancestor_concept_id = '21601832' THEN 'C09A/B/C/D/X'
				WHEN b.ancestor_concept_id = '21601848' THEN 'C09A/B/C/D/X'
				
				ELSE '00'
				END AS AHT_class 
					FROM (
						SELECT x.person_id, x.cohort_start_date, x.drug_exposure_start_date, 
						x.drug_concept_id, x.ancestor_concept_id, x.descendant_concept_id 
							FROM ( 
								(SELECT * FROM @target_database_schema.@target_cohort_table LEFT JOIN @cdm_database_schema.drug_exposure ON (@target_cohort_table.subject_id = drug_exposure.person_id)
								WHERE @target_cohort_table.cohort_definition_id=2 or @target_cohort_table.cohort_definition_id=3) f
								LEFT JOIN @cdm_database_schema.concept_ancestor ON (f.drug_concept_id=concept_ancestor.descendant_concept_id) 
							) x
						
					) b
					
				WHERE b.drug_exposure_start_date <= b.cohort_start_date
			
			) c
		) d 
		WHERE d.AHT_class != '00'
		GROUP BY d.person_id
		) e
	WHERE e.aht_count=1
	
