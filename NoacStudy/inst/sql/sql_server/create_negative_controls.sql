select codeset_id, concept_id 
INTO #Codesets
FROM
(
 SELECT c.codeset_id, c.concept_id FROM (select distinct I.codeset_id, I.concept_id FROM
( 
  select concept_id as codeset_id, concept_id from @cdm_database_schema.CONCEPT where concept_id in (36918850, 37420358, 36918858, 36617158, 36617163, 36314156, 36313741, 35607337, 35506612, 36718555, 36416637, 35506621, 35406402, 35406331, 35406349, 36516895, 35607026, 37420426, 37521024, 35406361, 37320079, 37522022, 35406391, 36516905, 35606949, 37520888, 36211101, 36110587, 36516909, 37119539, 36110951, 36315380, 37119529, 37119607, 36416695, 35607461, 36315910, 36315934, 37320318, 36110386, 36617187, 37320098, 36919212, 37420593, 37019460, 36617553, 36110933, 134438, 28060, 2313636, 42737560, 2213440, 2213473, 2109919, 2212542, 2212884, 2212945, 2212830) and invalid_reason is null
    UNION 

  select ca.ancestor_concept_id as codeset_id, c.concept_id
  from @cdm_database_schema.CONCEPT c
  join @cdm_database_schema.CONCEPT_ANCESTOR ca on c.concept_id = ca.descendant_concept_id
  and ca.ancestor_concept_id in (36918850, 37420358, 36918858, 36617158, 36617163, 36314156, 36313741, 35607337, 35506612, 36718555, 36416637, 35506621, 35406402, 35406331, 35406349, 36516895, 35607026, 37420426, 37521024, 35406361, 37320079, 37522022, 35406391, 36516905, 35606949, 37520888, 36211101, 36110587, 36516909, 37119539, 36110951, 36315380, 37119529, 37119607, 36416695, 35607461, 36315910, 36315934, 37320318, 36110386, 36617187, 37320098, 36919212, 37420593, 37019460, 36617553, 36110933, 134438, 28060, 2313636, 42737560, 2213440, 2213473, 2109919, 2212542, 2212884, 2212945, 2212830)
  and c.invalid_reason is null

) I
) C
) C
;


--Negative control conditions
DELETE FROM @target_database_schema.@target_cohort_definition_table WHERE COHORT_DEFINITION_ID in (select distinct codeset_id from #codesets);
INSERT INTO @target_database_schema.@target_cohort_definition_table (cohort_definition_id, cohort_definition_name, cohort_type)
	select concept_id as cohort_definition_id, 'First occurrence of ' + concept_name as cohort_definition_name, 2 as cohort_type
	from @cdm_database_schema.concept
	where concept_id in (select distinct codeset_id from #codesets)
;



DELETE FROM @target_database_schema.@target_cohort_table where cohort_definition_id in (select distinct codeset_id from #codesets);
INSERT INTO @target_database_schema.@target_cohort_table (cohort_definition_id, subject_id, cohort_start_date, cohort_end_date)
select P.codeset_id as cohort_definition_id, P.person_id as subject_id, P.start_date as cohort_start_date, P.end_date as cohort_end_date
FROM
(
  select P.codeset_id, P.person_id, P.start_date, P.end_date, ROW_NUMBER() OVER (PARTITION BY codeset_id, person_id ORDER BY start_date ASC) ordinal
  FROM 
  (
  select c.codeset_id, C.person_id, C.condition_start_date as start_date, COALESCE(C.condition_end_date, DATEADD(day,1,C.condition_start_date)) as end_date, C.CONDITION_CONCEPT_ID as TARGET_CONCEPT_ID
from 
(
        select c.codeset_id, co.*, ROW_NUMBER() over (PARTITION BY c.codeset_id, co.person_id ORDER BY co.condition_start_date) as ordinal
        FROM @cdm_database_schema.CONDITION_OCCURRENCE co
		INNER JOIN #codesets c on co.condition_concept_id = c.concept_id
) C



UNION
select c.codeset_id, C.person_id, C.procedure_date as start_date, DATEADD(d,1,C.procedure_date) as END_DATE, C.procedure_concept_id as TARGET_CONCEPT_ID
from 
(
  select c.codeset_id, po.*, ROW_NUMBER() over (PARTITION BY c.codeset_id, po.person_id ORDER BY po.procedure_date) as ordinal
  FROM @cdm_database_schema.PROCEDURE_OCCURRENCE po
INNER JOIN #codesets c on po.procedure_concept_id = c.concept_id
) C



  ) P
) P
JOIN @cdm_database_schema.observation_period OP on P.person_id = OP.person_id and P.start_date between OP.observation_period_start_date and op.observation_period_end_date
WHERE DATEADD(day,0,OP.OBSERVATION_PERIOD_START_DATE) <= P.START_DATE AND DATEADD(day,0,P.START_DATE) <= OP.OBSERVATION_PERIOD_END_DATE AND P.ordinal = 1
;



TRUNCATE TABLE #Codesets;
DROP TABLE #Codesets;


