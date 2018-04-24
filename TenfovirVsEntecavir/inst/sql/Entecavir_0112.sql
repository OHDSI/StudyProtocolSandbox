CREATE TABLE #Codesets (
  codeset_id int NOT NULL,
  concept_id bigint NOT NULL
)
;

INSERT INTO #Codesets (codeset_id, concept_id)
SELECT 0 as codeset_id, c.concept_id FROM (select distinct I.concept_id FROM
( 
  select concept_id from @cdm_database_schema.CONCEPT where concept_id in (1710281,19011093)and invalid_reason is null
UNION  select c.concept_id
  from @cdm_database_schema.CONCEPT c
  join @cdm_database_schema.CONCEPT_ANCESTOR ca on c.concept_id = ca.descendant_concept_id
  and ca.ancestor_concept_id in (1710281,19011093)
  and c.invalid_reason is null

) I
LEFT JOIN
(
  select concept_id from @cdm_database_schema.CONCEPT where concept_id in (42874226,42874225,42874222,42874224,42874221,40241984,40241983,40241982,40241981,40241980,40166596,40166595,40134707,40134708,19124374,40124351,40124350,19124373,19124372,1710316,19063361,1703093)and invalid_reason is null

) E ON I.concept_id = E.concept_id
WHERE E.concept_id is null
) C;
INSERT INTO #Codesets (codeset_id, concept_id)
SELECT 1 as codeset_id, c.concept_id FROM (select distinct I.concept_id FROM
( 
  select concept_id from @cdm_database_schema.CONCEPT where concept_id in (1711246)and invalid_reason is null
UNION  select c.concept_id
  from @cdm_database_schema.CONCEPT c
  join @cdm_database_schema.CONCEPT_ANCESTOR ca on c.concept_id = ca.descendant_concept_id
  and ca.ancestor_concept_id in (1711246)
  and c.invalid_reason is null

) I
) C;
INSERT INTO #Codesets (codeset_id, concept_id)
SELECT 2 as codeset_id, c.concept_id FROM (select distinct I.concept_id FROM
( 
  select concept_id from @cdm_database_schema.CONCEPT where concept_id in (73571,75053,4187096)and invalid_reason is null
UNION  select c.concept_id
  from @cdm_database_schema.CONCEPT c
  join @cdm_database_schema.CONCEPT_ANCESTOR ca on c.concept_id = ca.descendant_concept_id
  and ca.ancestor_concept_id in (73571,75053,4187096)
  and c.invalid_reason is null

) I
) C;
INSERT INTO #Codesets (codeset_id, concept_id)
SELECT 3 as codeset_id, c.concept_id FROM (select distinct I.concept_id FROM
( 
  select concept_id from @cdm_database_schema.CONCEPT where concept_id in (439674)and invalid_reason is null
UNION  select c.concept_id
  from @cdm_database_schema.CONCEPT c
  join @cdm_database_schema.CONCEPT_ANCESTOR ca on c.concept_id = ca.descendant_concept_id
  and ca.ancestor_concept_id in (439674)
  and c.invalid_reason is null

) I
) C;
INSERT INTO #Codesets (codeset_id, concept_id)
SELECT 4 as codeset_id, c.concept_id FROM (select distinct I.concept_id FROM
( 
  select concept_id from @cdm_database_schema.CONCEPT where concept_id in (439727)and invalid_reason is null
UNION  select c.concept_id
  from @cdm_database_schema.CONCEPT c
  join @cdm_database_schema.CONCEPT_ANCESTOR ca on c.concept_id = ca.descendant_concept_id
  and ca.ancestor_concept_id in (439727)
  and c.invalid_reason is null

) I
) C;


with primary_events (event_id, person_id, start_date, end_date, op_start_date, op_end_date, visit_occurrence_id) as
(
-- Begin Primary Events
select row_number() over (PARTITION BY P.person_id order by P.start_date) as event_id, P.person_id, P.start_date, P.end_date, OP.observation_period_start_date as op_start_date, OP.observation_period_end_date as op_end_date, P.visit_occurrence_id
FROM
(
  select P.person_id, P.start_date, P.end_date, row_number() OVER (PARTITION BY person_id ORDER BY start_date ASC) ordinal, P.visit_occurrence_id
  FROM 
  (
  -- Begin Drug Exposure Criteria
select C.person_id, C.drug_exposure_id as event_id, C.drug_exposure_start_date as start_date, COALESCE(C.drug_exposure_end_date, DATEADD(day, 1, C.drug_exposure_start_date)) as end_date, C.drug_concept_id as TARGET_CONCEPT_ID, C.visit_occurrence_id
from 
(
  select de.*, row_number() over (PARTITION BY de.person_id ORDER BY de.drug_exposure_start_date, de.drug_exposure_id) as ordinal
  FROM @cdm_database_schema.DRUG_EXPOSURE de
where de.drug_concept_id in (SELECT concept_id from  #Codesets where codeset_id = 1)
) C


-- End Drug Exposure Criteria

  ) P
) P
JOIN @cdm_database_schema.observation_period OP on P.person_id = OP.person_id and P.start_date >=  OP.observation_period_start_date and P.start_date <= op.observation_period_end_date
WHERE DATEADD(day,0,OP.OBSERVATION_PERIOD_START_DATE) <= P.START_DATE AND DATEADD(day,0,P.START_DATE) <= OP.OBSERVATION_PERIOD_END_DATE AND P.ordinal = 1
-- End Primary Events

)
SELECT event_id, person_id, start_date, end_date, op_start_date, op_end_date, visit_occurrence_id
INTO #qualified_events
FROM 
(
  select pe.event_id, pe.person_id, pe.start_date, pe.end_date, pe.op_start_date, pe.op_end_date, row_number() over (partition by pe.person_id order by pe.start_date ASC) as ordinal, pe.visit_occurrence_id
  FROM primary_events pe
  
JOIN (
-- Begin Criteria Group
select 0 as index_id, person_id, event_id
FROM
(
  select E.person_id, E.event_id 
  FROM primary_events E
  LEFT JOIN
  (
    -- Begin Correlated Criteria
SELECT 0 as index_id, p.person_id, p.event_id
FROM primary_events P
LEFT JOIN
(
  -- Begin Drug Exposure Criteria
select C.person_id, C.drug_exposure_id as event_id, C.drug_exposure_start_date as start_date, COALESCE(C.drug_exposure_end_date, DATEADD(day, 1, C.drug_exposure_start_date)) as end_date, C.drug_concept_id as TARGET_CONCEPT_ID, C.visit_occurrence_id
from 
(
  select de.*, row_number() over (PARTITION BY de.person_id ORDER BY de.drug_exposure_start_date, de.drug_exposure_id) as ordinal
  FROM @cdm_database_schema.DRUG_EXPOSURE de
where de.drug_concept_id in (SELECT concept_id from  #Codesets where codeset_id = 0)
) C


-- End Drug Exposure Criteria

) A on A.person_id = P.person_id and A.START_DATE >= P.OP_START_DATE AND A.START_DATE <= P.OP_END_DATE AND A.START_DATE >= DATEADD(day,-730,P.START_DATE) and A.START_DATE <= DATEADD(day,0,P.START_DATE) AND A.END_DATE >= DATEADD(day,0,P.START_DATE) AND A.END_DATE <= DATEADD(day,7,P.START_DATE)
GROUP BY p.person_id, p.event_id
HAVING COUNT(A.TARGET_CONCEPT_ID) <= 0
-- End Correlated Criteria

  ) CQ on E.person_id = CQ.person_id and E.event_id = CQ.event_id
  GROUP BY E.person_id, E.event_id
  HAVING COUNT(index_id) = 1
) G
-- End Criteria Group
) AC on AC.person_id = pe.person_id and AC.event_id = pe.event_id

) QE
WHERE QE.ordinal = 1
;


create table #inclusionRuleCohorts 
(
  inclusion_rule_id bigint,
  person_id bigint,
  event_id bigint
)
;
INSERT INTO #inclusionRuleCohorts (inclusion_rule_id, person_id, event_id)
select 0 as inclusion_rule_id, person_id, event_id
FROM 
(
  select pe.person_id, pe.event_id
  FROM #qualified_events pe
  
JOIN (
-- Begin Criteria Group
select 0 as index_id, person_id, event_id
FROM
(
  select E.person_id, E.event_id 
  FROM #qualified_events E
  LEFT JOIN
  (
    -- Begin Correlated Criteria
SELECT 0 as index_id, p.person_id, p.event_id
FROM #qualified_events P
LEFT JOIN
(
  -- Begin Condition Occurrence Criteria
SELECT C.person_id, C.condition_occurrence_id as event_id, C.condition_start_date as start_date, COALESCE(C.condition_end_date, DATEADD(day,1,C.condition_start_date)) as end_date, C.CONDITION_CONCEPT_ID as TARGET_CONCEPT_ID, C.visit_occurrence_id
FROM 
(
  SELECT co.*, row_number() over (PARTITION BY co.person_id ORDER BY co.condition_start_date, co.condition_occurrence_id) as ordinal
  FROM @cdm_database_schema.CONDITION_OCCURRENCE co
  where co.condition_concept_id in (SELECT concept_id from  #Codesets where codeset_id = 4)
) C


-- End Condition Occurrence Criteria

) A on A.person_id = P.person_id and A.START_DATE >= P.OP_START_DATE AND A.START_DATE <= P.OP_END_DATE AND A.START_DATE >= P.OP_START_DATE and A.START_DATE <= DATEADD(day,0,P.START_DATE)
GROUP BY p.person_id, p.event_id
HAVING COUNT(A.TARGET_CONCEPT_ID) <= 0
-- End Correlated Criteria

  ) CQ on E.person_id = CQ.person_id and E.event_id = CQ.event_id
  GROUP BY E.person_id, E.event_id
  HAVING COUNT(index_id) = 1
) G
-- End Criteria Group
) AC on AC.person_id = pe.person_id AND AC.event_id = pe.event_id
) Results
;


with cteIncludedEvents(event_id, person_id, start_date, end_date, op_start_date, op_end_date, ordinal) as
(
  SELECT event_id, person_id, start_date, end_date, op_start_date, op_end_date, row_number() over (partition by person_id order by start_date ASC) as ordinal
  from
  (
    select Q.event_id, Q.person_id, Q.start_date, Q.end_date, Q.op_start_date, Q.op_end_date, SUM(coalesce(POWER(cast(2 as bigint), I.inclusion_rule_id), 0)) as inclusion_rule_mask
    from #qualified_events Q
    LEFT JOIN #inclusionRuleCohorts I on I.person_id = Q.person_id and I.event_id = Q.event_id
    GROUP BY Q.event_id, Q.person_id, Q.start_date, Q.end_date, Q.op_start_date, Q.op_end_date
  ) MG -- matching groups

  -- the matching group with all bits set ( POWER(2,# of inclusion rules) - 1 = inclusion_rule_mask
  WHERE (MG.inclusion_rule_mask = POWER(cast(2 as bigint),1)-1)

)
select event_id, person_id, start_date, end_date, op_start_date, op_end_date
into #included_events
FROM cteIncludedEvents Results
WHERE Results.ordinal = 1
;

-- Apply end date stratagies
-- by default, all events extend to the op_end_date.
select event_id, person_id, op_end_date as end_date
into #cohort_ends
from #included_events;





with collapse_constructor_input (person_id, start_date, end_date) as
(
	select F.person_id, F.start_date, F.end_date
	FROM (
	  select I.event_id, I.person_id, I.start_date, E.end_date, row_number() over (partition by I.person_id, I.event_id order by E.end_date) as ordinal 
	  from #included_events I
	  join #cohort_ends E on I.event_id = E.event_id and I.person_id = E.person_id and E.end_date >= I.start_date
	) F
	WHERE F.ordinal = 1
)
select person_id, start_date, end_date
into #collapse_constructor_input
from collapse_constructor_input
;

-- era constructor
WITH cteSource (person_id, start_date, end_date, groupid) AS
(
	SELECT
		person_id  
		, start_date
		, end_date
		, dense_rank() over(order by person_id) as groupid
	FROM #collapse_constructor_input as so
)
,
--------------------------------------------------------------------------------------------------------------
cteEndDates (groupid, end_date) AS -- the magic
(	
	SELECT
		groupid
		, DATEADD(day,-1 * 0, event_date)  as end_date
	FROM
	(
		SELECT
			groupid
			, event_date
			, event_type
			, MAX(start_ordinal) OVER (PARTITION BY groupid ORDER BY event_date, event_type ROWS UNBOUNDED PRECEDING) AS start_ordinal 
			, ROW_NUMBER() OVER (PARTITION BY groupid ORDER BY event_date, event_type) AS overall_ord
		FROM
		(

			SELECT
				groupid
				, start_date AS event_date
				, -1 AS event_type
				, ROW_NUMBER() OVER (PARTITION BY groupid ORDER BY start_date) AS start_ordinal
			FROM cteSource
		
			UNION ALL
		

			SELECT
				groupid
				, DATEADD(day,0,end_date) as end_date
				, 1 AS event_type
				, NULL
			FROM cteSource
		) RAWDATA
	) e
	WHERE (2 * e.start_ordinal) - e.overall_ord = 0
),
--------------------------------------------------------------------------------------------------------------
cteEnds (groupid, start_date, end_date) AS
(
	SELECT
		 c.groupid
		, c.start_date
		, MIN(e.end_date) AS era_end_date
	FROM cteSource c
	JOIN cteEndDates e ON c.groupid = e.groupid AND e.end_date >= c.start_date
	GROUP BY
		 c.groupid
		, c.start_date
)
select person_id, start_date, end_date
into #collapse_constructor_output
from
(
	select distinct person_id , min(b.start_date) as start_date, b.end_date
	from
		(select distinct person_id, groupid from cteSource) as a
	inner join
		cteEnds as b
	on a.groupid = b.groupid
	group by person_id, end_date
) q
;


DELETE FROM @target_database_schema.@target_cohort_table where cohort_definition_id = @target_cohort_id;
INSERT INTO @target_database_schema.@target_cohort_table (cohort_definition_id, subject_id, cohort_start_date, cohort_end_date)
select @target_cohort_id as cohort_definition_id, person_id, start_date, end_date
FROM #collapse_constructor_output CO --@output: change depending on what is selected for collapse construction
;



TRUNCATE TABLE #collapse_constructor_input;
DROP TABLE #collapse_constructor_input;

TRUNCATE TABLE #collapse_constructor_output;
DROP TABLE #collapse_constructor_output;

TRUNCATE TABLE #cohort_ends;
DROP TABLE #cohort_ends;

TRUNCATE TABLE #inclusionRuleCohorts;
DROP TABLE #inclusionRuleCohorts;

TRUNCATE TABLE #qualified_events;
DROP TABLE #qualified_events;

TRUNCATE TABLE #included_events;
DROP TABLE #included_events;

TRUNCATE TABLE #Codesets;
DROP TABLE #Codesets;