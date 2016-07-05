CREATE TABLE #Codesets (
  codeset_id int NOT NULL,
  concept_id bigint NOT NULL
)
;

INSERT INTO #Codesets (codeset_id, concept_id)
SELECT 2 as codeset_id, c.concept_id FROM (select distinct I.concept_id FROM
( 
  select concept_id from @cdm_database_schema.CONCEPT where concept_id in (375545)and invalid_reason is null
UNION  select c.concept_id
  from @cdm_database_schema.CONCEPT c
  join @cdm_database_schema.CONCEPT_ANCESTOR ca on c.concept_id = ca.descendant_concept_id
  and ca.ancestor_concept_id in (375545)
  and c.invalid_reason is null

) I
LEFT JOIN
(
  select concept_id from @cdm_database_schema.CONCEPT where concept_id in (441846,436118,435810,377864,4051632,376973,372624,380513,380722,372905,4323127,441006,381279,374646,376401)and invalid_reason is null
UNION  select c.concept_id
  from @cdm_database_schema.CONCEPT c
  join @cdm_database_schema.CONCEPT_ANCESTOR ca on c.concept_id = ca.descendant_concept_id
  and ca.ancestor_concept_id in (441846,436118,435810,377864,4051632,376973,372624,380513,380722,372905,4323127,441006,381279,374646,376401)
  and c.invalid_reason is null

) E ON I.concept_id = E.concept_id
WHERE E.concept_id is null
) C;

select row_number() over (order by P.person_id, P.start_date) as event_id, P.person_id, P.start_date, P.end_date, OP.observation_period_start_date as op_start_date, OP.observation_period_end_date as op_end_date
INTO #PrimaryCriteriaEvents
FROM
(
  select P.person_id, P.start_date, P.end_date, ROW_NUMBER() OVER (PARTITION BY person_id ORDER BY start_date ASC) ordinal
  FROM 
  (
  select C.person_id, C.condition_start_date as start_date, COALESCE(C.condition_end_date, DATEADD(day,1,C.condition_start_date)) as end_date, C.CONDITION_CONCEPT_ID as TARGET_CONCEPT_ID
from 
(
        select co.*, ROW_NUMBER() over (PARTITION BY co.person_id ORDER BY co.condition_start_date) as ordinal
        FROM @cdm_database_schema.CONDITION_OCCURRENCE co
where co.condition_concept_id in (SELECT concept_id from  #Codesets where codeset_id = 2)
) C

WHERE C.ordinal = 1

  ) P
) P
JOIN @cdm_database_schema.observation_period OP on P.person_id = OP.person_id and P.start_date between OP.observation_period_start_date and op.observation_period_end_date
WHERE DATEADD(day,365,OP.OBSERVATION_PERIOD_START_DATE) <= P.START_DATE AND DATEADD(day,0,P.START_DATE) <= OP.OBSERVATION_PERIOD_END_DATE AND P.ordinal = 1
;


SELECT event_id, person_id, start_date, end_date, op_start_date, op_end_date
INTO #cohort_candidate
FROM 
(
  select RawEvents.*, row_number() over (partition by RawEvents.person_id order by RawEvents.start_date ASC) as ordinal
  FROM
  (
    select pe.event_id, pe.person_id, pe.start_date, pe.end_date, pe.op_start_date, pe.op_end_date
    FROM #PrimaryCriteriaEvents pe
    
JOIN (
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
where co.condition_concept_id in (SELECT concept_id from  #Codesets where codeset_id = 2)
) C
LEFT JOIN @cdm_database_schema.PROVIDER PR on C.provider_id = PR.provider_id
WHERE PR.specialty_concept_id in (38004463,38004481,38004701)

) A on A.person_id = P.person_id and A.START_DATE BETWEEN P.OP_START_DATE AND P.OP_END_DATE AND A.START_DATE BETWEEN DATEADD(day,1,P.START_DATE) and DATEADD(day,365,P.START_DATE)
GROUP BY p.event_id
HAVING COUNT(A.TARGET_CONCEPT_ID) >= 1


  ) CQ
  GROUP BY event_id
  HAVING COUNT(index_id) = 1
) G
) AC on AC.event_id = pe.event_id

  ) RawEvents
) Results

;

create table #inclusionRuleCohorts 
(
  inclusion_rule_id bigint,
  event_id bigint
)
;


-- the matching group with all bits set ( POWER(2,# of inclusion rules) - 1 = inclusion_rule_mask
DELETE FROM @target_database_schema.@target_cohort_table where cohort_definition_id = @target_cohort_id;
INSERT INTO @target_database_schema.@target_cohort_table (cohort_definition_id, subject_id, cohort_start_date, cohort_end_date)
select @target_cohort_id as cohort_definition_id, MG.person_id, MG.start_date, MG.end_date
from
(
  select C.event_id, C.person_id, C.start_date, C.end_date, SUM(coalesce(POWER(cast(2 as bigint), I.inclusion_rule_id), 0)) as inclusion_rule_mask
  from #cohort_candidate C
  LEFT JOIN #inclusionRuleCohorts I on I.event_id = C.event_id
  GROUP BY C.event_id, C.person_id, C.start_date, C.end_date
) MG -- matching groups
{0 != 0}?{
WHERE (MG.inclusion_rule_mask = POWER(cast(2 as bigint),0)-1)
}
;


TRUNCATE TABLE #inclusionRuleCohorts;
DROP TABLE #inclusionRuleCohorts;

TRUNCATE TABLE #PrimaryCriteriaEvents;
DROP TABLE #PrimaryCriteriaEvents;

TRUNCATE TABLE #Codesets;
DROP TABLE #Codesets;

