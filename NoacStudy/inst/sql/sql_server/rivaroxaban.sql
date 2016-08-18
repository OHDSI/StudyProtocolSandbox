select codeset_id, concept_id 
INTO #Codesets
FROM
(
 SELECT 0 as codeset_id, c.concept_id FROM (select distinct I.concept_id FROM
( 
  select DISTINCT concept_id from @cdm_database_schema.CONCEPT where concept_id in (1310149) and invalid_reason is null
    UNION 

  select c.concept_id
  from @cdm_database_schema.CONCEPT c
  join @cdm_database_schema.CONCEPT_ANCESTOR ca on c.concept_id = ca.descendant_concept_id
  and ca.ancestor_concept_id in (1310149)
  and c.invalid_reason is null

) I
) C
UNION
SELECT 1 as codeset_id, c.concept_id FROM (select distinct I.concept_id FROM
( 
  select DISTINCT concept_id from @cdm_database_schema.CONCEPT where concept_id in (313217,314665,4108832) and invalid_reason is null
    UNION 

  select c.concept_id
  from @cdm_database_schema.CONCEPT c
  join @cdm_database_schema.CONCEPT_ANCESTOR ca on c.concept_id = ca.descendant_concept_id
  and ca.ancestor_concept_id in (313217,314665,4108832)
  and c.invalid_reason is null

) I
) C
UNION
SELECT 3 as codeset_id, c.concept_id FROM (select distinct I.concept_id FROM
( 
  select DISTINCT concept_id from @cdm_database_schema.CONCEPT where concept_id in (40241331) and invalid_reason is null
    UNION 

  select c.concept_id
  from @cdm_database_schema.CONCEPT c
  join @cdm_database_schema.CONCEPT_ANCESTOR ca on c.concept_id = ca.descendant_concept_id
  and ca.ancestor_concept_id in (40241331)
  and c.invalid_reason is null

) I
) C
UNION
SELECT 4 as codeset_id, c.concept_id FROM (select distinct I.concept_id FROM
( 
  select DISTINCT concept_id from @cdm_database_schema.CONCEPT where concept_id in (40241331,40228152,1310149,43013024) and invalid_reason is null
    UNION 

  select c.concept_id
  from @cdm_database_schema.CONCEPT c
  join @cdm_database_schema.CONCEPT_ANCESTOR ca on c.concept_id = ca.descendant_concept_id
  and ca.ancestor_concept_id in (40241331,40228152,1310149,43013024)
  and c.invalid_reason is null

) I
) C
UNION
SELECT 5 as codeset_id, c.concept_id FROM (select distinct I.concept_id FROM
( 
  select DISTINCT concept_id from @cdm_database_schema.CONCEPT where concept_id in (4013355,4013356,4060089,4020159,4121484,4339971,4119522,43020459,4145884,44782431,4195003,312773,4181749,4165384,44783274,2617334,2617335,2001447,2001448,40757085,40757036,43528049,315273,4047527,4110937,4304541) and invalid_reason is null
    UNION 

  select c.concept_id
  from @cdm_database_schema.CONCEPT c
  join @cdm_database_schema.CONCEPT_ANCESTOR ca on c.concept_id = ca.descendant_concept_id
  and ca.ancestor_concept_id in (4013355,4013356,4060089,4020159,4121484,4339971,4119522,43020459,4145884,44782431,4195003,312773,4181749,4165384,44783274,2617334,2617335,2001447,2001448,40757085,40757036,43528049,315273,4047527,4110937,4304541)
  and c.invalid_reason is null

) I
) C
UNION
SELECT 6 as codeset_id, c.concept_id FROM (select distinct I.concept_id FROM
( 
  select DISTINCT concept_id from @cdm_database_schema.CONCEPT where concept_id in (42898160) and invalid_reason is null
  
) I
) C
UNION
SELECT 7 as codeset_id, c.concept_id FROM (select distinct I.concept_id FROM
( 
  select DISTINCT concept_id from @cdm_database_schema.CONCEPT where concept_id in (4120120,2003564,4324124,435649,4126124,4137616,4099603,4092504,4297658,4300106,4297919,4300099,313232,40480136,44782924,4181476,2101833,2617550,2617551,2617552,43533281,44786469,44786470,44786471) and invalid_reason is null
    UNION 

  select c.concept_id
  from @cdm_database_schema.CONCEPT c
  join @cdm_database_schema.CONCEPT_ANCESTOR ca on c.concept_id = ca.descendant_concept_id
  and ca.ancestor_concept_id in (4120120,2003564,4324124)
  and c.invalid_reason is null

) I
) C
UNION
SELECT 8 as codeset_id, c.concept_id FROM (select distinct I.concept_id FROM
( 
  select DISTINCT concept_id from @cdm_database_schema.CONCEPT where concept_id in (2003626,4324754,40664909,2721092,4046829,4022805,4021107,4343000,4346636,4346505,4197300,4347789,37521745,4322471,2109589,2109586,2109584,4002215,4163566) and invalid_reason is null
    UNION 

  select c.concept_id
  from @cdm_database_schema.CONCEPT c
  join @cdm_database_schema.CONCEPT_ANCESTOR ca on c.concept_id = ca.descendant_concept_id
  and ca.ancestor_concept_id in (2003626,4324754,40664909,2721092,4046829,4022805,4021107,4343000,4346636,4346505,4197300,4347789,37521745,4322471,2109589,2109586,2109584,4002215,4163566)
  and c.invalid_reason is null

) I
) C
UNION
SELECT 9 as codeset_id, c.concept_id FROM (select distinct I.concept_id FROM
( 
  select DISTINCT concept_id from @cdm_database_schema.CONCEPT where concept_id in (2101634,2101635,2101660,2103931,2104836,2104837,2104838,2104839,2104840,2105103,2105128,2105129,2000070,2000069,2000071,2000072,2000073,2000074,2000075,2000076,2000078,2000079,2000080,2000081,2000082,2000083,2000084,2000085,2005891,4203771,4162099,4207955,4134857,2104835,2005902,2005904,45887894,4266062,4010119,4001859) and invalid_reason is null
    UNION 

  select c.concept_id
  from @cdm_database_schema.CONCEPT c
  join @cdm_database_schema.CONCEPT_ANCESTOR ca on c.concept_id = ca.descendant_concept_id
  and ca.ancestor_concept_id in (4203771,4162099,4207955,4134857,45887894,4266062,4010119,4001859)
  and c.invalid_reason is null

) I
) C
) C
;

select row_number() over (order by P.person_id) as event_id, P.person_id, P.start_date, P.end_date, OP.observation_period_start_date as op_start_date, OP.observation_period_end_date as op_end_date
INTO #PrimaryCriteriaEvents
FROM
(
  select P.person_id, P.start_date, P.end_date, ROW_NUMBER() OVER (PARTITION BY person_id ORDER BY start_date ASC) ordinal
  FROM 
  (
  select C.person_id, C.drug_era_start_date as start_date, C.drug_era_end_date as end_date, C.drug_concept_id as TARGET_CONCEPT_ID
from 
(
  select de.*, ROW_NUMBER() over (PARTITION BY de.person_id ORDER BY de.drug_era_start_date) as ordinal
  FROM @cdm_database_schema.DRUG_ERA de
where de.drug_concept_id in (SELECT concept_id from  #Codesets where codeset_id = 3)
) C
JOIN @cdm_database_schema.PERSON P on C.person_id = P.person_id
WHERE C.ordinal = 1
AND C.drug_era_start_date > '2011-11-1'
AND YEAR(C.drug_era_start_date) - P.year_of_birth >= 21

  ) P
) P
JOIN @cdm_database_schema.observation_period OP on P.person_id = OP.person_id and P.start_date between OP.observation_period_start_date and op.observation_period_end_date
WHERE DATEADD(day,183,OP.OBSERVATION_PERIOD_START_DATE) <= P.START_DATE AND DATEADD(day,0,P.START_DATE) <= OP.OBSERVATION_PERIOD_END_DATE AND P.ordinal = 1
;


DELETE FROM @target_database_schema.@target_cohort_table where cohort_definition_id = @cohort_definition_id;
INSERT INTO @target_database_schema.@target_cohort_table (cohort_definition_id, subject_id, cohort_start_date, cohort_end_date)
select @cohort_definition_id as cohort_definition_id, person_id as subject_id, start_date as cohort_start_date, end_date as cohort_end_date
FROM 
(
  select RawEvents.*, row_number() over (partition by RawEvents.person_id order by RawEvents.start_date ASC) as ordinal
  FROM
  (
    select pe.person_id, pe.start_date, pe.end_date
    FROM #PrimaryCriteriaEvents pe
    
JOIN (
select 0 as index_id, event_id
FROM
(
  select event_id FROM
  (
    select 0 as index_id, event_id
FROM
(
  select event_id FROM
  (
    SELECT 0 as index_id, p.event_id
FROM #PrimaryCriteriaEvents P
LEFT JOIN
(
  select C.person_id, C.condition_start_date as start_date, COALESCE(C.condition_end_date, DATEADD(day,1,C.condition_start_date)) as end_date, C.CONDITION_CONCEPT_ID as TARGET_CONCEPT_ID
from 
(
        select co.*, ROW_NUMBER() over (PARTITION BY co.person_id ORDER BY co.condition_start_date) as ordinal
        FROM @cdm_database_schema.CONDITION_OCCURRENCE co
where co.condition_concept_id in (SELECT concept_id from  #Codesets where codeset_id = 1)
) C



) A on A.person_id = P.person_id and A.START_DATE BETWEEN P.OP_START_DATE and DATEADD(day,0,P.START_DATE)
GROUP BY p.event_id
HAVING COUNT(A.TARGET_CONCEPT_ID) >= 1


  ) CQ
  GROUP BY event_id
  HAVING COUNT(index_id) = 1
) G

UNION
select 1 as index_id, event_id
FROM
(
  select event_id FROM
  (
    SELECT 0 as index_id, p.event_id
FROM #PrimaryCriteriaEvents P
LEFT JOIN
(
  select C.person_id, C.drug_exposure_start_date as start_date, COALESCE(C.drug_exposure_end_date, DATEADD(day, 1, C.drug_exposure_start_date)) as end_date, C.drug_concept_id as TARGET_CONCEPT_ID
from 
(
  select de.*, ROW_NUMBER() over (PARTITION BY de.person_id ORDER BY de.drug_exposure_start_date) as ordinal
  FROM @cdm_database_schema.DRUG_EXPOSURE de
where de.drug_concept_id in (SELECT concept_id from  #Codesets where codeset_id = 0)
) C



) A on A.person_id = P.person_id and A.START_DATE BETWEEN P.OP_START_DATE and DATEADD(day,-1,P.START_DATE)
GROUP BY p.event_id
HAVING COUNT(A.TARGET_CONCEPT_ID) <= 0


  ) CQ
  GROUP BY event_id
  HAVING COUNT(index_id) = 1
) G

UNION
select 2 as index_id, event_id
FROM
(
  select event_id FROM
  (
    SELECT 0 as index_id, p.event_id
FROM #PrimaryCriteriaEvents P
LEFT JOIN
(
  select C.person_id, C.drug_exposure_start_date as start_date, COALESCE(C.drug_exposure_end_date, DATEADD(day, 1, C.drug_exposure_start_date)) as end_date, C.drug_concept_id as TARGET_CONCEPT_ID
from 
(
  select de.*, ROW_NUMBER() over (PARTITION BY de.person_id ORDER BY de.drug_exposure_start_date) as ordinal
  FROM @cdm_database_schema.DRUG_EXPOSURE de
where de.drug_concept_id in (SELECT concept_id from  #Codesets where codeset_id = 3)
) C



) A on A.person_id = P.person_id and A.START_DATE BETWEEN P.OP_START_DATE and DATEADD(day,-1,P.START_DATE)
GROUP BY p.event_id
HAVING COUNT(A.TARGET_CONCEPT_ID) <= 0


  ) CQ
  GROUP BY event_id
  HAVING COUNT(index_id) = 1
) G

UNION
select 3 as index_id, event_id
FROM
(
  select event_id FROM
  (
    SELECT 0 as index_id, p.event_id
FROM #PrimaryCriteriaEvents P
LEFT JOIN
(
  select C.person_id, C.drug_exposure_start_date as start_date, COALESCE(C.drug_exposure_end_date, DATEADD(day, 1, C.drug_exposure_start_date)) as end_date, C.drug_concept_id as TARGET_CONCEPT_ID
from 
(
  select de.*, ROW_NUMBER() over (PARTITION BY de.person_id ORDER BY de.drug_exposure_start_date) as ordinal
  FROM @cdm_database_schema.DRUG_EXPOSURE de
where de.drug_concept_id in (SELECT concept_id from  #Codesets where codeset_id = 4)
) C



) A on A.person_id = P.person_id and A.START_DATE BETWEEN DATEADD(day,-183,P.START_DATE) and DATEADD(day,-1,P.START_DATE)
GROUP BY p.event_id
HAVING COUNT(A.TARGET_CONCEPT_ID) <= 0


  ) CQ
  GROUP BY event_id
  HAVING COUNT(index_id) = 1
) G

UNION
select 4 as index_id, event_id
FROM
(
  select event_id FROM
  (
    SELECT 0 as index_id, p.event_id
FROM #PrimaryCriteriaEvents P
LEFT JOIN
(
  select C.person_id, C.condition_start_date as start_date, COALESCE(C.condition_end_date, DATEADD(day,1,C.condition_start_date)) as end_date, C.CONDITION_CONCEPT_ID as TARGET_CONCEPT_ID
from 
(
        select co.*, ROW_NUMBER() over (PARTITION BY co.person_id ORDER BY co.condition_start_date) as ordinal
        FROM @cdm_database_schema.CONDITION_OCCURRENCE co
where co.condition_concept_id in (SELECT concept_id from  #Codesets where codeset_id = 5)
) C



) A on A.person_id = P.person_id and A.START_DATE BETWEEN P.OP_START_DATE and DATEADD(day,0,P.START_DATE)
GROUP BY p.event_id
HAVING COUNT(A.TARGET_CONCEPT_ID) <= 0


UNION
SELECT 1 as index_id, p.event_id
FROM #PrimaryCriteriaEvents P
LEFT JOIN
(
  select C.person_id, C.procedure_date as start_date, DATEADD(d,1,C.procedure_date) as END_DATE, C.procedure_concept_id as TARGET_CONCEPT_ID
from 
(
  select po.*, ROW_NUMBER() over (PARTITION BY po.person_id ORDER BY po.procedure_date) as ordinal
  FROM @cdm_database_schema.PROCEDURE_OCCURRENCE po
where po.procedure_concept_id in (SELECT concept_id from  #Codesets where codeset_id = 5)
) C



) A on A.person_id = P.person_id and A.START_DATE BETWEEN P.OP_START_DATE and DATEADD(day,0,P.START_DATE)
GROUP BY p.event_id
HAVING COUNT(A.TARGET_CONCEPT_ID) <= 0


UNION
SELECT 2 as index_id, p.event_id
FROM #PrimaryCriteriaEvents P
LEFT JOIN
(
  select C.person_id, C.observation_date as start_date, DATEADD(d,1,C.observation_date) as END_DATE, C.observation_concept_id as TARGET_CONCEPT_ID
from 
(
  select o.*, ROW_NUMBER() over (PARTITION BY o.person_id ORDER BY o.observation_date) as ordinal
  FROM @cdm_database_schema.OBSERVATION o
where o.observation_concept_id in (SELECT concept_id from  #Codesets where codeset_id = 5)
) C



) A on A.person_id = P.person_id and A.START_DATE BETWEEN P.OP_START_DATE and DATEADD(day,0,P.START_DATE)
GROUP BY p.event_id
HAVING COUNT(A.TARGET_CONCEPT_ID) <= 0


  ) CQ
  GROUP BY event_id
  HAVING COUNT(index_id) = 3
) G

UNION
select 5 as index_id, event_id
FROM
(
  select event_id FROM
  (
    SELECT 0 as index_id, p.event_id
FROM #PrimaryCriteriaEvents P
LEFT JOIN
(
  select C.person_id, C.condition_start_date as start_date, COALESCE(C.condition_end_date, DATEADD(day,1,C.condition_start_date)) as end_date, C.CONDITION_CONCEPT_ID as TARGET_CONCEPT_ID
from 
(
        select co.*, ROW_NUMBER() over (PARTITION BY co.person_id ORDER BY co.condition_start_date) as ordinal
        FROM @cdm_database_schema.CONDITION_OCCURRENCE co
where co.condition_concept_id in (SELECT concept_id from  #Codesets where codeset_id = 7)
) C



) A on A.person_id = P.person_id and A.START_DATE BETWEEN DATEADD(day,-30,P.START_DATE) and DATEADD(day,0,P.START_DATE)
GROUP BY p.event_id
HAVING COUNT(A.TARGET_CONCEPT_ID) <= 0


UNION
SELECT 1 as index_id, p.event_id
FROM #PrimaryCriteriaEvents P
LEFT JOIN
(
  select C.person_id, C.procedure_date as start_date, DATEADD(d,1,C.procedure_date) as END_DATE, C.procedure_concept_id as TARGET_CONCEPT_ID
from 
(
  select po.*, ROW_NUMBER() over (PARTITION BY po.person_id ORDER BY po.procedure_date) as ordinal
  FROM @cdm_database_schema.PROCEDURE_OCCURRENCE po
where po.procedure_concept_id in (SELECT concept_id from  #Codesets where codeset_id = 7)
) C



) A on A.person_id = P.person_id and A.START_DATE BETWEEN DATEADD(day,-30,P.START_DATE) and DATEADD(day,0,P.START_DATE)
GROUP BY p.event_id
HAVING COUNT(A.TARGET_CONCEPT_ID) <= 0


UNION
SELECT 2 as index_id, p.event_id
FROM #PrimaryCriteriaEvents P
LEFT JOIN
(
  select C.person_id, C.observation_date as start_date, DATEADD(d,1,C.observation_date) as END_DATE, C.observation_concept_id as TARGET_CONCEPT_ID
from 
(
  select o.*, ROW_NUMBER() over (PARTITION BY o.person_id ORDER BY o.observation_date) as ordinal
  FROM @cdm_database_schema.OBSERVATION o
where o.observation_concept_id in (SELECT concept_id from  #Codesets where codeset_id = 7)
) C



) A on A.person_id = P.person_id and A.START_DATE BETWEEN DATEADD(day,-30,P.START_DATE) and DATEADD(day,0,P.START_DATE)
GROUP BY p.event_id
HAVING COUNT(A.TARGET_CONCEPT_ID) <= 0


  ) CQ
  GROUP BY event_id
  HAVING COUNT(index_id) = 3
) G

UNION
select 6 as index_id, event_id
FROM
(
  select event_id FROM
  (
    SELECT 0 as index_id, p.event_id
FROM #PrimaryCriteriaEvents P
LEFT JOIN
(
  select C.person_id, C.condition_start_date as start_date, COALESCE(C.condition_end_date, DATEADD(day,1,C.condition_start_date)) as end_date, C.CONDITION_CONCEPT_ID as TARGET_CONCEPT_ID
from 
(
        select co.*, ROW_NUMBER() over (PARTITION BY co.person_id ORDER BY co.condition_start_date) as ordinal
        FROM @cdm_database_schema.CONDITION_OCCURRENCE co
where co.condition_concept_id in (SELECT concept_id from  #Codesets where codeset_id = 8)
) C



) A on A.person_id = P.person_id and A.START_DATE BETWEEN P.OP_START_DATE and DATEADD(day,0,P.START_DATE)
GROUP BY p.event_id
HAVING COUNT(A.TARGET_CONCEPT_ID) <= 0


UNION
SELECT 1 as index_id, p.event_id
FROM #PrimaryCriteriaEvents P
LEFT JOIN
(
  select C.person_id, C.procedure_date as start_date, DATEADD(d,1,C.procedure_date) as END_DATE, C.procedure_concept_id as TARGET_CONCEPT_ID
from 
(
  select po.*, ROW_NUMBER() over (PARTITION BY po.person_id ORDER BY po.procedure_date) as ordinal
  FROM @cdm_database_schema.PROCEDURE_OCCURRENCE po
where po.procedure_concept_id in (SELECT concept_id from  #Codesets where codeset_id = 8)
) C



) A on A.person_id = P.person_id and A.START_DATE BETWEEN P.OP_START_DATE and DATEADD(day,0,P.START_DATE)
GROUP BY p.event_id
HAVING COUNT(A.TARGET_CONCEPT_ID) <= 0


UNION
SELECT 2 as index_id, p.event_id
FROM #PrimaryCriteriaEvents P
LEFT JOIN
(
  select C.person_id, C.observation_date as start_date, DATEADD(d,1,C.observation_date) as END_DATE, C.observation_concept_id as TARGET_CONCEPT_ID
from 
(
  select o.*, ROW_NUMBER() over (PARTITION BY o.person_id ORDER BY o.observation_date) as ordinal
  FROM @cdm_database_schema.OBSERVATION o
where o.observation_concept_id in (SELECT concept_id from  #Codesets where codeset_id = 8)
) C



) A on A.person_id = P.person_id and A.START_DATE BETWEEN P.OP_START_DATE and DATEADD(day,0,P.START_DATE)
GROUP BY p.event_id
HAVING COUNT(A.TARGET_CONCEPT_ID) <= 0


  ) CQ
  GROUP BY event_id
  HAVING COUNT(index_id) = 3
) G

UNION
select 7 as index_id, event_id
FROM
(
  select event_id FROM
  (
    SELECT 0 as index_id, p.event_id
FROM #PrimaryCriteriaEvents P
LEFT JOIN
(
  select C.person_id, C.procedure_date as start_date, DATEADD(d,1,C.procedure_date) as END_DATE, C.procedure_concept_id as TARGET_CONCEPT_ID
from 
(
  select po.*, ROW_NUMBER() over (PARTITION BY po.person_id ORDER BY po.procedure_date) as ordinal
  FROM @cdm_database_schema.PROCEDURE_OCCURRENCE po
where po.procedure_concept_id in (SELECT concept_id from  #Codesets where codeset_id = 9)
) C



) A on A.person_id = P.person_id and A.START_DATE BETWEEN DATEADD(day,-183,P.START_DATE) and DATEADD(day,0,P.START_DATE)
GROUP BY p.event_id
HAVING COUNT(A.TARGET_CONCEPT_ID) <= 0


  ) CQ
  GROUP BY event_id
  HAVING COUNT(index_id) = 1
) G

  ) CQ
  GROUP BY event_id
  HAVING COUNT(index_id) = 8
) G
) AC on AC.event_id = pe.event_id
  ) RawEvents
) Results
WHERE Results.ordinal = 1
;

TRUNCATE TABLE #Codesets;
DROP TABLE #Codesets;

TRUNCATE TABLE #PrimaryCriteriaEvents;
DROP TABLE #PrimaryCriteriaEvents;
