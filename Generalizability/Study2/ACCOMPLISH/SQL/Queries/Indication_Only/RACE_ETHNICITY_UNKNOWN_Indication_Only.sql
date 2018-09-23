SELECT 'Race Ethnicity Unknown', COUNT(d.subject_id), Null, Null, Null, Null, Null, Null, Null FROM (
	SELECT DISTINCT ON (c.subject_id) c.subject_id, c.eth_race FROM
		(
		SELECT b.subject_id,
		CASE
		WHEN b.ethnicity_concept_id = '0' AND b.race_concept_id = '8515' THEN 'OTH'
		WHEN b.ethnicity_concept_id = '38003563' AND b.race_concept_id = '38003613' THEN 'OTH'
		WHEN b.ethnicity_concept_id = '0' AND b.race_concept_id = '8516' THEN 'AFA'
		WHEN b.ethnicity_concept_id = '38003564' AND b.race_concept_id = '8527' THEN 'CAU'
		WHEN b.ethnicity_concept_id = '38003563' AND b.race_concept_id = '8515' THEN 'OTH'
		WHEN b.ethnicity_concept_id = '38003564' AND b.race_concept_id = '8522' THEN 'OTH'
		WHEN b.ethnicity_concept_id = '38003564' AND b.race_concept_id = '8657' THEN 'OTH'
		WHEN b.ethnicity_concept_id = '38003563' AND b.race_concept_id = '8516' THEN 'AFA'
		WHEN b.ethnicity_concept_id = '0' AND b.race_concept_id = '38003613' THEN 'OTH'
		WHEN b.ethnicity_concept_id = '38003564' AND b.race_concept_id = '8552' THEN 'UNK'
		WHEN b.ethnicity_concept_id = '0' AND b.race_concept_id = '8522' THEN 'UNK'
		WHEN b.ethnicity_concept_id = '0' AND b.race_concept_id = '8527' THEN 'CAU'
		WHEN b.ethnicity_concept_id = '0' AND b.race_concept_id = '8552' THEN 'OTH'
		WHEN b.ethnicity_concept_id = '38003564' AND b.race_concept_id = '38003613' THEN 'OTH'
		WHEN b.ethnicity_concept_id = '0' AND b.race_concept_id = '8657' THEN 'OTH'
		WHEN b.ethnicity_concept_id = '38003563' AND b.race_concept_id = '8527' THEN 'HISP'
		WHEN b.ethnicity_concept_id = '38003564' AND b.race_concept_id = '8515' THEN 'OTH'
		WHEN b.ethnicity_concept_id = '38003563' AND b.race_concept_id = '8522' THEN 'HISP'
		WHEN b.ethnicity_concept_id = '38003563' AND b.race_concept_id = '8657' THEN 'HISP'
		WHEN b.ethnicity_concept_id = '38003564' AND b.race_concept_id = '8516' THEN 'AFA'
		WHEN b.ethnicity_concept_id = '38003563' AND b.race_concept_id = '8552' THEN 'HISP'
		END  AS eth_race FROM
			(SELECT a.subject_id, a.ethnicity_concept_id, a.race_concept_id FROM 
				( SELECT * FROM @target_database_schema.@target_cohort_table LEFT JOIN @cdm_database_schema.person ON (@target_cohort_table.subject_id = person.person_id) ) a 
				WHERE cohort_definition_id=1
			GROUP BY subject_id, ethnicity_concept_id, race_concept_id 
			) b
		)c 
	) d WHERE d.eth_race = 'UNK'

