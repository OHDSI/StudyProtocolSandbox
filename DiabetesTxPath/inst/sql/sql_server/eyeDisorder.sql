CREATE TABLE #Codesets (
  codeset_id int NOT NULL,
  concept_id bigint NOT NULL
)
;

INSERT INTO #Codesets (codeset_id, concept_id)
SELECT 0 as codeset_id, c.concept_id FROM (select distinct I.concept_id FROM
( 
  select concept_id from @cdm_database_schema.CONCEPT where concept_id in (4078543,4317976,436108,4196110,4195495,4198119,4210131,4006784,4105173,4209538,4008573,441846,436118,381295,40481141,4191001,432311,4213414,4259620,4338899,4199963,372315,375256,4035651,4318983,4105159,4007451,4208203,4317977,4102183,4001501,4199036,4070182,4070183,435810,4196108,375545,4301387,443569,377864,4334867,376117,381566,4334869,4051632,4334868,376973,372624,372894,4338904,4195496,4208210,432312,4208201,4199038,4279395,4219330,376400,375546,4214756,4334129,4100720,45757718,4070185,45757344,443791,380513,380505,45770920,4280227,4069800,4069803,4100889,4102696,45757716,381392,4274483,4099981,4105600,4068699,4008296,378534,4103579,44783428,432895,4225524,4041191,4338903,4196117,376979,4225656,4221495,4164175,380097,4162095,4334884,4101478,4161670,4174977,4227210,4226121,44805628,4338901,4199039,4109548,4246656,4334886,4334130,434145,4221344,4223463,373756,4336007,4210872,4336012,437541,4334258,436687,4228181,436398,436110,440396,436972,438151,432626,4109421,437276,4244668,434928,4170134,4150163,4104232,4282930,4151767,4108979,45772019,4336013,4102186,433767,432908,438155,433768,4334260,4334254,4309435,4334253,4053646,4164176,4310845,45765456,379811,45757567,437553,376965,4318685,4335597,4335596,40487893,4210432,4195051,4210871,376399,40482507,45770919,4220818,373770,437269,4319589,4210874,4161420,4109424,4232575,380722,441561,45770830,4003103,4334870,377285,4208206,4195056,378743,45757435,4195498,4152554,377552,45770881,4130588,372905,40482880,4199942,4334259,44782843,374338,4269870,4161671,376683,45763583,43530656,377274,373769,4230391,439297,4235260,4212435,4255402,4255400,4252356,4215961,4060974,4252215,4246964,4255281,4247107,4186542,4235261,4255399,4255401,4212441,4218499,441284,4109420,4216823,437851,4168942,4048386,4225529,4048060,380101,434030,441556,4311056,4336001,436975,4334257,4132632,4335999,4197734,436976,438749,4231284,4323127,4159747,4105172,40479994,435543,4102185,4316869,435262,380096,43530685,45757065,4195043,4266042,4164174,4195044,4210128,4210129,4336000,4338900,45757798,4109401,45763584,45770831,4335998,437273,4230930,4336003,4208211,4317952,4102647,436109,437542,4304106,4311715,376103,45757064,4228115,4119139,45770986,373766,375250,375251,379009,443519,443520,4102697,4338888,4213393,4217546,4065195,4152558,441005,4318691,4316071,4072218,376114,4290822,4266637,4334887,4021365,441006,377555,4007944,435809,433473,4104230,45757599,4302891,4319588,376688,4154554,4196118,381279,4196119,376520,4109544,374642,374646,4108983,377848,4322086,45769873,45773064,376401,4071600,4195502,4194237,4334244,4210137,4194464,4269871,4290823,4221962,4164632,4266041,4217520,4339019,44783427)and invalid_reason is null

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
  select pe.event_id, pe.person_id, pe.start_date, pe.end_date, pe.op_start_date, pe.op_end_date, row_number() over (partition by pe.person_id order by pe.start_date ASC) as ordinal, pe.visit_occurrence_id
  FROM primary_events pe
  
) QE

;


create table #inclusionRuleCohorts 
(
  inclusion_rule_id bigint,
  person_id bigint,
  event_id bigint
)
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





with collapse_input (person_id, start_date, end_date) as
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
into #collapse_input
from collapse_input
;

-- era constructor
WITH cteSource (person_id, start_date, end_date, groupid) AS
(
  SELECT
    person_id  
    , start_date
    , end_date
    , dense_rank() over(order by person_id) as groupid
  FROM #collapse_input as so
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
into #collapse_output
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
FROM #collapse_output CO --@output: change depending on what is selected for collapse construction
;



TRUNCATE TABLE #collapse_input;
DROP TABLE #collapse_input;

TRUNCATE TABLE #collapse_output;
DROP TABLE #collapse_output;

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

