CREATE TABLE #Codesets (
  codeset_id int NOT NULL,
  concept_id bigint NOT NULL
)
;

INSERT INTO #Codesets (codeset_id, concept_id)
SELECT 0 as codeset_id, c.concept_id FROM (select distinct I.concept_id FROM
( 
  select concept_id from @vocabulary_database_schema.CONCEPT where concept_id in (4155297,443392,439392)and invalid_reason is null
UNION  select c.concept_id
  from @vocabulary_database_schema.CONCEPT c
  join @vocabulary_database_schema.CONCEPT_ANCESTOR ca on c.concept_id = ca.descendant_concept_id
  and ca.ancestor_concept_id in (4155297,443392,439392)
  and c.invalid_reason is null

) I
LEFT JOIN
(
  select concept_id from @vocabulary_database_schema.CONCEPT where concept_id in (36715966,4111027,4111948,4298128,4295479,4112752,4300574,4298127,4110731,4111943,4300681,4174440,40488988,40486088,4298147,4297331,4298146,40486167,4111931,4290984,4300570,4112753,4111949,4301644,4166588,4112758,40492018,4301635,4301779,4291595,4300585,4298149,4309817,258981,4297353,4301780,4301665,4299143,4112102,4293714,4198437,4198436,4300694,4179980,4141249,4300571,4297192,4297193,4111920,4298846,4300670,4110740,4300690,439302,4092382,4091335,4095148,4095602,4091333,4095598,4092379,4310566,4095151,4095152,4095738,4092384,133150,4092380,4095737,4207920,40486656,4092381,4095603,4091337,4091336,4115297,4115295,4181353,4112871,4173358,4291293,4100425,4110722,4298129,4110723,4111933,4221977,4102385,4298233,4112760,40489940,36716631,37395579,4301516,40486118,4116086,4301517,4110733,4162978,4141250,4220469,37018963,36715782,4301669,4294435,4297358,4300703,4301668,4297357,4266193,4297356,4300702,4266805,4246794,4311497,440339,37110584,4247345,4247346,4312680,4247347,4247348,4247349,4246227,4312681,4246228,4247350,4246229,136916,4246230,435755,4247351,4312682,4312683,4246231,4312684,4246232,4311614,4247352,42709762,4312685,434291,4311617,4246233,4312686,4312687,4247353,4247354,4312688,4246234,133147,4311618,440658,4247355,36715783,4173353,4116063,4300096,4301282,4295476,4299134,4141248,4335884,4312943,4315661,4312012,4314349,4314350,4313930,4315678,4313931,4315679,4311331,4311332,4313932,4315680,4315681,4313933,4313934,4315683,4315684,4315685,4315686,4313935,4311333,4314351,4314352,4091762,4315793,4094406,4311334,4311335,42709758,4315794,4315795,4314354,4313936,4311336,4311337,4314355,4097426,4314356,4314357,4314358,4313937,4314359,42709759,4314360,4315796,4311346,4300572,4301667,4301781,4111921,4269784,4301538,4298848,4301512)and invalid_reason is null
UNION  select c.concept_id
  from @vocabulary_database_schema.CONCEPT c
  join @vocabulary_database_schema.CONCEPT_ANCESTOR ca on c.concept_id = ca.descendant_concept_id
  and ca.ancestor_concept_id in (36715966,4111027,4111948,4298128,4295479,4112752,4300574,4298127,4110731,4111943,4300681,4174440,40488988,40486088,4298147,4297331,4298146,40486167,4111931,4290984,4300570,4112753,4111949,4301644,4166588,4112758,40492018,4301635,4301779,4291595,4300585,4298149,4309817,258981,4297353,4301780,4301665,4299143,4112102,4293714,4198437,4198436,4300694,4179980,4141249,4300571,4297192,4297193,4111920,4298846,4300670,4110740,4300690,439302,4092382,4091335,4095148,4095602,4091333,4095598,4092379,4310566,4095151,4095152,4095738,4092384,133150,4092380,4095737,4207920,40486656,4092381,4095603,4091337,4091336,4115297,4115295,4181353,4112871,4173358,4291293,4100425,4110722,4298129,4110723,4111933,4221977,4102385,4298233,4112760,40489940,36716631,37395579,4301516,40486118,4116086,4301517,4110733,4162978,4141250,4220469,37018963,36715782,4301669,4294435,4297358,4300703,4301668,4297357,4266193,4297356,4300702,4266805,4246794,4311497,440339,37110584,4247345,4247346,4312680,4247347,4247348,4247349,4246227,4312681,4246228,4247350,4246229,136916,4246230,435755,4247351,4312682,4312683,4246231,4312684,4246232,4311614,4247352,42709762,4312685,434291,4311617,4246233,4312686,4312687,4247353,4247354,4312688,4246234,133147,4311618,440658,4247355,36715783,4173353,4116063,4300096,4301282,4295476,4299134,4141248,4335884,4312943,4315661,4312012,4314349,4314350,4313930,4315678,4313931,4315679,4311331,4311332,4313932,4315680,4315681,4313933,4313934,4315683,4315684,4315685,4315686,4313935,4311333,4314351,4314352,4091762,4315793,4094406,4311334,4311335,42709758,4315794,4315795,4314354,4313936,4311336,4311337,4314355,4097426,4314356,4314357,4314358,4313937,4314359,42709759,4314360,4315796,4311346,4300572,4301667,4301781,4111921,4269784,4301538,4298848,4301512)
  and c.invalid_reason is null

) E ON I.concept_id = E.concept_id
WHERE E.concept_id is null
) C;


with primary_events (event_id, person_id, start_date, end_date, op_start_date, op_end_date, visit_occurrence_id) as
(
-- Begin Primary Events
select row_number() over (PARTITION BY P.person_id order by P.start_date) as event_id, P.person_id, P.start_date, P.end_date, OP.observation_period_start_date as op_start_date, OP.observation_period_end_date as op_end_date, cast(P.visit_occurrence_id as bigint) as visit_occurrence_id
FROM
(
  select P.person_id, P.start_date, P.end_date, row_number() OVER (PARTITION BY person_id ORDER BY start_date ASC) ordinal, cast(P.visit_occurrence_id as bigint) as visit_occurrence_id
  FROM 
  (
  -- Begin Condition Occurrence Criteria
SELECT C.person_id, C.condition_occurrence_id as event_id, C.condition_start_date as start_date, COALESCE(C.condition_end_date, DATEADD(day,1,C.condition_start_date)) as end_date, C.CONDITION_CONCEPT_ID as TARGET_CONCEPT_ID, C.visit_occurrence_id
FROM 
(
  SELECT co.*, row_number() over (PARTITION BY co.person_id ORDER BY co.condition_start_date, co.condition_occurrence_id) as ordinal
  FROM @cdm_database_schema.CONDITION_OCCURRENCE co
  where co.condition_concept_id in (SELECT concept_id from  #Codesets where codeset_id = 0)
) C


-- End Condition Occurrence Criteria

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
  select pe.event_id, pe.person_id, pe.start_date, pe.end_date, pe.op_start_date, pe.op_end_date, row_number() over (partition by pe.person_id order by pe.start_date ASC) as ordinal, cast(pe.visit_occurrence_id as bigint) as visit_occurrence_id
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
    select ET.person_id, ET.event_id from primary_events ET
  ) CQ on E.person_id = CQ.person_id and E.event_id = CQ.event_id
  GROUP BY E.person_id, E.event_id
  
) G
-- End Criteria Group
) AC on AC.person_id = pe.person_id and AC.event_id = pe.event_id

) QE
WHERE QE.ordinal = 1
;

--- Inclusion Rule Inserts

create table #inclusion_events (inclusion_rule_id bigint,
	person_id bigint,
	event_id bigint
);

with cteIncludedEvents(event_id, person_id, start_date, end_date, op_start_date, op_end_date, ordinal) as
(
  SELECT event_id, person_id, start_date, end_date, op_start_date, op_end_date, row_number() over (partition by person_id order by start_date ASC) as ordinal
  from
  (
    select Q.event_id, Q.person_id, Q.start_date, Q.end_date, Q.op_start_date, Q.op_end_date, SUM(coalesce(POWER(cast(2 as bigint), I.inclusion_rule_id), 0)) as inclusion_rule_mask
    from #qualified_events Q
    LEFT JOIN #inclusion_events I on I.person_id = Q.person_id and I.event_id = Q.event_id
    GROUP BY Q.event_id, Q.person_id, Q.start_date, Q.end_date, Q.op_start_date, Q.op_end_date
  ) MG -- matching groups

)
select event_id, person_id, start_date, end_date, op_start_date, op_end_date
into #included_events
FROM cteIncludedEvents Results
WHERE Results.ordinal = 1
;



-- generate cohort periods into #final_cohort
with cohort_ends (event_id, person_id, end_date) as
(
	-- cohort exit dates
  -- By default, cohort exit at the event's op end date
select event_id, person_id, op_end_date as end_date from #included_events
),
first_ends (person_id, start_date, end_date) as
(
	select F.person_id, F.start_date, F.end_date
	FROM (
	  select I.event_id, I.person_id, I.start_date, E.end_date, row_number() over (partition by I.person_id, I.event_id order by E.end_date) as ordinal 
	  from #included_events I
	  join cohort_ends E on I.event_id = E.event_id and I.person_id = E.person_id and E.end_date >= I.start_date
	) F
	WHERE F.ordinal = 1
)
select person_id, start_date, end_date
INTO #cohort_rows
from first_ends;

with cteEndDates (person_id, end_date) AS -- the magic
(	
	SELECT
		person_id
		, DATEADD(day,-1 * 0, event_date)  as end_date
	FROM
	(
		SELECT
			person_id
			, event_date
			, event_type
			, MAX(start_ordinal) OVER (PARTITION BY person_id ORDER BY event_date, event_type ROWS UNBOUNDED PRECEDING) AS start_ordinal 
			, ROW_NUMBER() OVER (PARTITION BY person_id ORDER BY event_date, event_type) AS overall_ord
		FROM
		(
			SELECT
				person_id
				, start_date AS event_date
				, -1 AS event_type
				, ROW_NUMBER() OVER (PARTITION BY person_id ORDER BY start_date) AS start_ordinal
			FROM #cohort_rows
		
			UNION ALL
		

			SELECT
				person_id
				, DATEADD(day,0,end_date) as end_date
				, 1 AS event_type
				, NULL
			FROM #cohort_rows
		) RAWDATA
	) e
	WHERE (2 * e.start_ordinal) - e.overall_ord = 0
),
cteEnds (person_id, start_date, end_date) AS
(
	SELECT
		 c.person_id
		, c.start_date
		, MIN(e.end_date) AS era_end_date
	FROM #cohort_rows c
	JOIN cteEndDates e ON c.person_id = e.person_id AND e.end_date >= c.start_date
	GROUP BY c.person_id, c.start_date
)
select person_id, min(start_date) as start_date, end_date
into #final_cohort
from cteEnds
group by person_id, end_date
;

DELETE FROM @target_database_schema.@target_cohort_table where cohort_definition_id = @target_cohort_id;
INSERT INTO @target_database_schema.@target_cohort_table (cohort_definition_id, subject_id, cohort_start_date, cohort_end_date)
select @target_cohort_id as cohort_definition_id, person_id, start_date, end_date 
FROM #final_cohort CO
;





TRUNCATE TABLE #cohort_rows;
DROP TABLE #cohort_rows;

TRUNCATE TABLE #final_cohort;
DROP TABLE #final_cohort;

TRUNCATE TABLE #inclusion_events;
DROP TABLE #inclusion_events;

TRUNCATE TABLE #qualified_events;
DROP TABLE #qualified_events;

TRUNCATE TABLE #included_events;
DROP TABLE #included_events;

TRUNCATE TABLE #Codesets;
DROP TABLE #Codesets;

