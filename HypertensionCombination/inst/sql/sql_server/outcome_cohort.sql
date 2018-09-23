/*
@cdmDatabaseSchema
@resultsDatabaseSchema
#precohort 
@exposureTable
@htn_medication_id_table
*/
CREATE TABLE #precohort (cohort_definition_id INT, subject_id BIGINT, cohort_start_date DATE, cohort_end_date DATE);

CREATE TABLE #Codesets (
  codeset_id int NOT NULL,
  concept_id bigint NOT NULL
)
;

INSERT INTO #Codesets (codeset_id, concept_id)
--Ischemic heart disease
SELECT 3 as codeset_id, c.concept_id FROM (select distinct I.concept_id FROM
( 
  select concept_id from @cdmDatabaseSchema.CONCEPT where concept_id in (321318, 315296, 4127089, 321318, 321318, 321318, 321318, 312327, 434376, 438170, 312327, 312327, 444406, 444406, 444406, 444406, 444406, 312327, 4108217, 4108677, 4108218, 4108217, 4108217, 319844, 4108215, 319844, 319844, 315286, 317576, 317576, 317576, 317576, 317576, 317576, 314666, 4110961, 4124683, 315286, 315286, 315830, 315832, 316995, 319039, 4011131, 4030582, 4046022, 40481919, 4048534, 4051874, 4068938, 4069186, 4078531, 4092936, 4094054, 4094055, 4096252, 4097848, 4108172, 4111393, 4116486, 4119455, 4119456, 4119457, 4119613, 4119942, 4119943, 4119944, 4119945, 4119946, 4119947, 4119948, 4119949, 4119950, 4119951, 4121464, 4121465, 4121466, 4121467, 4121468, 4124682, 4108669, 4108670, 4108673, 4124684, 4124685, 4124686, 4126801, 4134723, 4138833, 4145696, 4145721, 4147223, 4151046, 4153091, 4154704, 4155007, 4155008, 4155009, 4155962, 4155963, 4161455, 4161456, 4161457, 4161973, 4161974, 4168972, 4170094, 4172865, 4173171, 4173632, 4175846, 4178129, 4178321, 4178622, 4184827, 4185302, 4185932, 4186397, 4189939, 4198141, 4199962, 4200113, 4201629, 4206867, 4207921, 4209308, 4209541, 4215140, 4215259, 4219755, 4225958, 4231426, 4242670, 4243371, 4243372, 4252385, 4262446, 4263712, 4264145, 4267568, 4270024, 4275436, 42872402, 4296653, 43020460, 43020461, 43020660, 43022045, 4303359, 4304192, 4310270, 4323202, 4324413, 4324893, 4329847, 44782712, 44782769, 44783791, 44784623, 44806109, 44808600, 45766075, 45766076, 45766113, 45766114, 45766115, 45766116, 45766117, 45766150, 45766151, 45766238, 45766241, 45771322, 45773170, 46269996, 46270158, 46270159, 46270160, 46270161, 46270162, 46270163, 46270164, 46273495, 46274044, 438438, 438447, 439693, 441579, 43531588, 436706)and invalid_reason is null

) I
) C;
INSERT INTO #Codesets (codeset_id, concept_id)

--MI
SELECT 4 as codeset_id, c.concept_id FROM (select distinct I.concept_id FROM
( 
  select concept_id from @cdmDatabaseSchema.CONCEPT where concept_id in (312327, 434376, 438170, 312327, 312327, 444406, 444406, 444406, 444406, 444406, 312327, 319039, 4011131, 4051874, 4108669, 4119456, 4119457, 4119943, 4119944, 4119945, 4119946, 4119947, 4119948, 4121464, 4121465, 4121466, 4124684, 4124685, 4126801, 4145721, 4147223, 4151046, 4178129, 4243372, 4267568, 4270024, 4275436, 4296653, 43020460, 43020461, 4303359, 4324413, 44782712, 44782769, 45766075, 45766076, 45766115, 45766116, 45766150, 45766151, 45771322, 46270158, 46270159, 46270160, 46270161, 46270162, 46270163, 46270164, 46273495, 46274044, 438438, 438447, 441579, 436706)and invalid_reason is null

) I
) C;
INSERT INTO #Codesets (codeset_id, concept_id)
--STROKE
SELECT 6 as codeset_id, c.concept_id FROM (select distinct I.concept_id FROM
( 
  select concept_id from @cdmDatabaseSchema.CONCEPT where concept_id in (381440, 4006295, 4009796, 4014781, 4017105, 4017107, 4023571, 4025201, 4031045, 4039439, 4043731, 4043732, 4045734, 4045735, 4045737, 4045738, 4045740, 4045741, 4045743, 4045744, 4045745, 4045746, 4045747, 4045748, 4046089, 4046090, 4046237, 4046358, 4046359, 4046360, 4046361, 4046362, 4046363, 4046364, 4046365, 4047731, 4047732, 40479572, 40480273, 4048133, 4048277, 4048278, 4048279, 4048606, 4048784, 40492969, 4049750, 4052462, 4071066, 4071589, 4071732, 4077086, 4077200, 4077201, 4077819, 4077827, 4077828, 4077958, 4077959, 4078314, 4078446, 4078447, 4078448, 4079021, 4079120, 4079430, 4079431, 4079432, 4079433, 4079434, 4079972, 4079973, 4080892, 4082161, 4082162, 4082163, 4085234, 4086178, 4090122, 4095178, 4099974, 4103390, 4106058, 252477, 255105, 256556, 256844, 260841, 261433, 373057, 373347, 377254, 379778, 380113, 380943, 4110186, 4112018, 4112019, 4112022, 4119140, 4120104, 4121664, 4126076, 4129290, 4129534, 4129535, 4130539, 4131383, 4134162, 4134421, 4136545, 4136546, 4137761, 4138327, 4139778, 4141405, 4142739, 4144154, 4145897, 4146185, 4147995, 4148906, 4151359, 4153352, 4154699, 4159140, 4159152, 4162754, 4168056, 4171122, 4171123, 4172545, 4173332, 4173481, 4174299, 4174848, 4176148, 4178726, 4180610, 4180743, 4183593, 4185701, 4189462, 4196275, 4196276, 4199890, 4201028, 4201094, 4201635, 4209442, 4211509, 4215954, 4216353, 4217146, 4219010, 4224614, 4229432, 4238315, 4242720, 4243309, 4249574, 4250507, 4263703, 4267862, 42872427, 42872434, 42873042, 42873044, 42873045, 42873046, 42873123, 42873157, 4289598, 4299377, 4301259, 4306943, 4310996, 4318408, 4319146, 433037, 433050, 433051, 433052, 433058, 433623, 433624, 4337830, 4338502, 433882, 433899, 434155, 434166, 434508, 4345688, 434756, 434785, 434789, 435104, 43530669, 43530670, 43530671, 43530674, 43530683, 43530727, 43530728, 43530851, 43531605, 43531607, 435378, 435390, 435391, 435672, 435931, 435938, 435959, 435960, 435964, 436258, 436519, 436526, 436553, 436557, 436841, 436842, 437106, 437133, 437388, 437413, 438003, 438279, 438285, 438595, 438596, 438873, 438894, 439040, 439171, 439182, 439194, 439847, 439932, 439944, 439949, 439950, 440236, 440244, 440250, 440251, 440531, 440537, 440561, 440869, 440870, 441158, 441432, 441709, 441985, 442341, 4110196, 4110676, 4111707, 4111710, 4111711, 4327350, 432743, 432752, 432764, 4328027, 443752, 443790, 443864, 444091, 444196, 444197, 444198, 44782730, 44782773, 44797721, 45766068, 45766118, 45766119, 45766120, 45766830, 45767658, 45772786, 45773167, 46270031, 46270111, 46270380, 46270381, 46271801, 46273491, 46273649, 4323618, 432474, 432475, 432478, 432923, 4108952, 432923, 432923, 432923, 432923, 4111708, 432923, 432923, 432923, 432923, 376713, 4049659, 4176892, 4218781, 4319328, 4326561, 4110185, 376713, 376713, 376713, 4111709, 436430, 443454, 4110189, 4110189, 4110189, 4110189, 4110189, 4110189, 4110190, 4110190, 4110190, 4110190, 4110190, 4110190, 4110189, 4110189, 4110189, 4110189, 4110189, 4110189, 4110192, 4110192, 4110192, 4110192, 4110192, 4110192, 4110192, 4108356, 4108356, 4108356, 4108356, 4108356, 4108356, 4108356, 4110192, 4110192, 4110192, 4110192, 4110192, 4110192, 4110192, 4111714, 443454, 443454, 381316) and invalid_reason is null

) I
) C;
INSERT INTO #Codesets (codeset_id, concept_id)
SELECT 7 as codeset_id, c.concept_id FROM (select distinct I.concept_id FROM
( 
  select concept_id from @cdmDatabaseSchema.CONCEPT where concept_id in (4110189,443454,4111714,4108356,4110190,4110192)and invalid_reason is null

) I
) C;
INSERT INTO #Codesets (codeset_id, concept_id)
SELECT 8 as codeset_id, c.concept_id FROM (select distinct I.concept_id FROM
( 
  select concept_id from @cdmDatabaseSchema.CONCEPT where concept_id in (4319328,4326561,4218781,376713,4176892,4110185,436430,4111709,4226021,432923,4108952,4111708,4049659)and invalid_reason is null

) I
) C;
INSERT INTO #Codesets (codeset_id, concept_id)
--HF
SELECT 9 as codeset_id, c.concept_id FROM (select distinct I.concept_id FROM
( 
  select concept_id from @cdmDatabaseSchema.CONCEPT where concept_id in (314378, 316139, 319835, 319835, 319835, 319835, 439846, 316139, 4004279, 4009047, 4014159, 4023479, 4030258, 40479192, 40479576, 40480602, 40480603, 40481042, 40481043, 40482857, 40486933, 4071869, 4079296, 4079695, 4103448, 4108244, 4108245, 4111554, 4124705, 4134890, 4138307, 4139864, 4141124, 4142561, 4172864, 4177493, 4184497, 4185565, 4193236, 4195785, 4195892, 4199500, 4205558, 4206009, 4215446, 4215802, 4229440, 4231738, 4233224, 4233424, 4242669, 4259490, 4264636, 4267800, 4273632, 4284562, 43020421, 43020657, 43021735, 43021736, 43021825, 43021826, 43021840, 43021841, 43021842, 43022054, 43022068, 4307356, 4311437, 4327205, 43530961, 439694, 439696, 439698, 442310, 443580, 443587, 444031, 444101, 44782428, 44782655, 44782713, 44782718, 44782719, 44782728, 44782733, 44784345, 44784442, 45766164, 45766165, 45766166, 45766167, 45766964, 45773075, 312338, 312927, 315295, 316994)and invalid_reason is null

) I
) C;
INSERT INTO #Codesets (codeset_id, concept_id)
--HTN
SELECT 10 as codeset_id, c.concept_id FROM (select distinct I.concept_id FROM
( 
  select concept_id from @cdmDatabaseSchema.CONCEPT where concept_id in (320128, 320128, 320128, 320128, 314103, 314423, 45757447, 4028951, 4049389, 4159755, 4302591, 44809026, 4058987, 4304837, 44783643, 44811110, 45771067, 4146816, 4217486, 44800519, 45771064, 321074, 44811932, 45757139, 45757445, 4263067, 4279525, 44809548, 4023318, 4179379, 4276511, 317898, 4062811, 4209293, 4277110, 44809027, 4034031, 4167358, 316866, 4028741, 4269358, 43020424, 44811933, 45768449, 4148205, 4215640, 44783644, 320456, 4227607, 4269635, 4321603, 4162306, 43021830, 45757137, 312648, 4057978, 45757444, 4083723, 42873163, 45757356, 45757787, 321638, 4151903, 4221991, 4262182, 4311246, 321080, 40481896, 4180283, 4199306, 4218088, 4242878, 4289933, 44809569, 45757446)and invalid_reason is null

) I
) C;
INSERT INTO #Codesets (codeset_id, concept_id)
SELECT 11 as codeset_id, c.concept_id FROM (select distinct I.concept_id FROM
( 
  select concept_id from @cdmDatabaseSchema.CONCEPT where concept_id in (4108805,319844,312327,312653,4332246,321318,314054,312337,4306703,4108832,321042,321319,376713,443454,381316,381591,315286,316999,4307356,321887,134057,318772,433208,320739,24966,320128,320425,321588,316139,195556,442604,201313,434056,317002,319843,4108234,313792,317309,313219,440417,315282,4175807,4226021,432923,4108217,4327889,4108817,4232337)and invalid_reason is null

) I
) C;
INSERT INTO #Codesets (codeset_id, concept_id)
SELECT 12 as codeset_id, c.concept_id FROM (select distinct I.concept_id FROM
( 
  select concept_id from @cdmDatabaseSchema.CONCEPT where concept_id in (1363749, 1335471, 19050216, 1308216, 19122327, 1341927, 1340128, 1310756, 1373225, 1331235, 1334456, 19102107, 19040051, 1342439, 999000, 999001, 999003, 40235485, 1351557, 1346686, 1347384, 1367500, 40226742, 1317640, 1308842, 999002)
  --add (cetapril, delapril, fimasartan, temocapril)  to ACEi/ARB group (999000, 999001, 999002, 999003)
  and invalid_reason is null
  
) I
) C;
INSERT INTO #Codesets (codeset_id, concept_id)
SELECT 13 as codeset_id, c.concept_id FROM (select distinct I.concept_id FROM
( 
  select concept_id from @cdmDatabaseSchema.CONCEPT where concept_id in (1319998, 1314002, 1322081, 1338005, 950370, 1346823, 19049145, 19063575, 1386957, 1307046, 1314577, 19024904, 1327978, 1345858, 1353766, 1313200, 999004)
  --add (bevantolol, 999004)  to BB group
  and invalid_reason is null
  
) I
) C;
INSERT INTO #Codesets (codeset_id, concept_id)
SELECT 14 as codeset_id, c.concept_id FROM (select distinct I.concept_id FROM
( 
  select concept_id from @cdmDatabaseSchema.CONCEPT where concept_id in (1328165,1353776,1326012,19004539,19015802,19071995,19102106,1318853,19113063,1319133,1319880,19020061,1307863
  ,1332418, 19089969, 1345141, 1318137 --amlodipine, clevidipine, mibefradil, nicardipine
  --add (benidipine, clinidipine, efonidipine)  to CCB group
  ,999005, 999006, 999007)and invalid_reason is null

) I
) C;
INSERT INTO #Codesets (codeset_id, concept_id)
SELECT 15 as codeset_id, c.concept_id FROM (select distinct I.concept_id FROM
( 
  select concept_id from @cdmDatabaseSchema.CONCEPT where concept_id in (1395058,974166,978555,907013,19010493)and invalid_reason is null --thiazide

) I
) C;



--OUTCOME COHORT--------------------------------------------------------------------
/*
@cdmDatabaseSchema
@cdmDatabaseSchema

@resultsDatabaseSchema
@resultsDatabaseSchema

@outcome_precohort_table
@outcome_precohort_table

@outcomeTable
@outcomeTable

*/

--------------------------------------------------------------------------------------------------------------------------------------------
--ANY DEATH START-----------------------------------------------------------------------------------------------------------------

/*
@cdm_database_schema
@cdmDatabaseSchema

@target_database_schema
@resultsDatabaseSchema

@target_cohort_table
@outcome_precohort_table

@target_cohort_id
0 (any death)
*/

select row_number() over (order by P.person_id, P.start_date) as event_id, P.person_id, P.start_date, P.end_date, OP.observation_period_start_date as op_start_date, OP.observation_period_end_date as op_end_date
INTO #primary_events
FROM
(
  select P.person_id, P.start_date, P.end_date, ROW_NUMBER() OVER (PARTITION BY person_id ORDER BY start_date ASC) ordinal
  FROM 
  (
  select C.person_id, C.death_date as start_date, DATEADD(d,1,C.death_date) as end_date, coalesce(C.cause_concept_id,0) as TARGET_CONCEPT_ID
from 
(
  select d.*
  FROM @cdmDatabaseSchema.DEATH d
) C


  ) P
) P
JOIN @cdmDatabaseSchema.observation_period OP on P.person_id = OP.person_id and P.start_date between OP.observation_period_start_date and op.observation_period_end_date
WHERE DATEADD(day,0,OP.OBSERVATION_PERIOD_START_DATE) <= P.START_DATE AND DATEADD(day,0,P.START_DATE) <= OP.OBSERVATION_PERIOD_END_DATE AND P.ordinal = 1
;


SELECT event_id, person_id, start_date, end_date, op_start_date, op_end_date
INTO #qualified_events
FROM 
(
  select pe.event_id, pe.person_id, pe.start_date, pe.end_date, pe.op_start_date, pe.op_end_date, row_number() over (partition by pe.person_id order by pe.start_date ASC) as ordinal
  FROM #primary_events pe
  
JOIN (
select 0 as index_id, event_id
FROM
(
  select event_id FROM
  (
    SELECT 0 as index_id, p.event_id
FROM #primary_events P
LEFT JOIN
(
  select C.person_id, C.condition_start_date as start_date, COALESCE(C.condition_end_date, DATEADD(day,1,C.condition_start_date)) as end_date, C.CONDITION_CONCEPT_ID as TARGET_CONCEPT_ID
from 
(
        select co.*, ROW_NUMBER() over (PARTITION BY co.person_id ORDER BY co.condition_start_date) as ordinal
        FROM @cdmDatabaseSchema.CONDITION_OCCURRENCE co
) C

) A on A.person_id = P.person_id and A.START_DATE >= P.OP_START_DATE AND A.START_DATE <= P.OP_END_DATE AND A.START_DATE >= P.OP_START_DATE and A.START_DATE <= DATEADD(day,0,P.START_DATE)
GROUP BY p.event_id
HAVING COUNT(A.TARGET_CONCEPT_ID) >= 1


  ) CQ
  GROUP BY event_id
  HAVING COUNT(index_id) = 1
) G
) AC on AC.event_id = pe.event_id

) QE
WHERE QE.ordinal = 1
;


create table #inclusionRuleCohorts 
(
  inclusion_rule_id bigint,
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
    LEFT JOIN #inclusionRuleCohorts I on I.event_id = Q.event_id
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

DELETE FROM #precohort where cohort_definition_id = 0;

INSERT INTO #precohort (cohort_definition_id, subject_id, cohort_start_date, cohort_end_date)
select 0 as cohort_definition_id, F.person_id, F.start_date, F.end_date
FROM (
  select Q.person_id, Q.start_date, E.end_date, row_number() over (partition by Q.event_id order by E.end_date) as ordinal 
  from #qualified_events Q
  join #cohort_ends E on Q.event_id = E.event_id and Q.person_id = E.person_id and E.end_date >= Q.start_date
) F
WHERE F.ordinal = 1
;

TRUNCATE TABLE #cohort_ends;
DROP TABLE #cohort_ends;

TRUNCATE TABLE #inclusionRuleCohorts;
DROP TABLE #inclusionRuleCohorts;

TRUNCATE TABLE #qualified_events;
DROP TABLE #qualified_events;

TRUNCATE TABLE #included_events;
DROP TABLE #included_events;

TRUNCATE TABLE #primary_events;
DROP TABLE #primary_events;

--ANY DEATH END---------------------------------------------------------------------
----------------------------------------------------------------------------------------------------


--------------------------------------------------------------------------------------------------------------------------------------------
--CARDIO/CEREBRAL MORTALITY START-----------------------------------------------------------------------------------------------------------------

/*
@cdm_database_schema
@cdmDatabaseSchema

@target_database_schema
@resultsDatabaseSchema

@target_cohort_table
@outcome_precohort_table

@target_cohort_id
1 (cardio-cerebral death)
*/

select row_number() over (order by P.person_id, P.start_date) as event_id, P.person_id, P.start_date, P.end_date, OP.observation_period_start_date as op_start_date, OP.observation_period_end_date as op_end_date
INTO #primary_events
FROM
(
  select P.person_id, P.start_date, P.end_date, ROW_NUMBER() OVER (PARTITION BY person_id ORDER BY start_date ASC) ordinal
  FROM 
  (
  select C.person_id, C.death_date as start_date, DATEADD(d,1,C.death_date) as end_date, coalesce(C.cause_concept_id,0) as TARGET_CONCEPT_ID
from 
(
  select d.*
  FROM @cdmDatabaseSchema.DEATH d
where d.cause_concept_id in (SELECT concept_id from  #Codesets where codeset_id = 11)
) C




  ) P
) P
JOIN @cdmDatabaseSchema.observation_period OP on P.person_id = OP.person_id and P.start_date between OP.observation_period_start_date and op.observation_period_end_date
WHERE DATEADD(day,0,OP.OBSERVATION_PERIOD_START_DATE) <= P.START_DATE AND DATEADD(day,0,P.START_DATE) <= OP.OBSERVATION_PERIOD_END_DATE AND P.ordinal = 1
;


SELECT event_id, person_id, start_date, end_date, op_start_date, op_end_date
INTO #qualified_events
FROM 
(
  select pe.event_id, pe.person_id, pe.start_date, pe.end_date, pe.op_start_date, pe.op_end_date, row_number() over (partition by pe.person_id order by pe.start_date ASC) as ordinal
  FROM #primary_events pe
  
JOIN (
select 0 as index_id, event_id
FROM
(
  select event_id FROM
  (
    SELECT 0 as index_id, p.event_id
FROM #primary_events P
LEFT JOIN
(
  select C.person_id, C.condition_start_date as start_date, COALESCE(C.condition_end_date, DATEADD(day,1,C.condition_start_date)) as end_date, C.CONDITION_CONCEPT_ID as TARGET_CONCEPT_ID
from 
(
        select co.*, ROW_NUMBER() over (PARTITION BY co.person_id ORDER BY co.condition_start_date) as ordinal
        FROM @cdmDatabaseSchema.CONDITION_OCCURRENCE co
where co.condition_concept_id in (SELECT concept_id from  #Codesets where codeset_id = 10)
) C



) A on A.person_id = P.person_id and A.START_DATE >= P.OP_START_DATE AND A.START_DATE <= P.OP_END_DATE AND A.START_DATE >= P.OP_START_DATE and A.START_DATE <= DATEADD(day,0,P.START_DATE)
GROUP BY p.event_id
HAVING COUNT(A.TARGET_CONCEPT_ID) >= 1


  ) CQ
  GROUP BY event_id
  HAVING COUNT(index_id) = 1
) G
) AC on AC.event_id = pe.event_id

) QE
WHERE QE.ordinal = 1
;


create table #inclusionRuleCohorts 
(
  inclusion_rule_id bigint,
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
    LEFT JOIN #inclusionRuleCohorts I on I.event_id = Q.event_id
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



DELETE FROM #precohort where cohort_definition_id = 1;

INSERT INTO #precohort (cohort_definition_id, subject_id, cohort_start_date, cohort_end_date)
select 1 as cohort_definition_id, F.person_id, F.start_date, F.end_date
FROM (
  select Q.person_id, Q.start_date, E.end_date, row_number() over (partition by Q.event_id order by E.end_date) as ordinal 
  from #qualified_events Q
  join #cohort_ends E on Q.event_id = E.event_id and Q.person_id = E.person_id and E.end_date >= Q.start_date
) F
WHERE F.ordinal = 1
;




TRUNCATE TABLE #cohort_ends;
DROP TABLE #cohort_ends;

TRUNCATE TABLE #inclusionRuleCohorts;
DROP TABLE #inclusionRuleCohorts;

TRUNCATE TABLE #qualified_events;
DROP TABLE #qualified_events;

TRUNCATE TABLE #included_events;
DROP TABLE #included_events;

TRUNCATE TABLE #primary_events;
DROP TABLE #primary_events;

--CARDIO/CEREBRAL MORTALITY END---------------------------------------------------------------------
----------------------------------------------------------------------------------------------------


-------------------------------------------------------------------------------------------------
--MI START---------------------------------------------------------------------------------------
/*
@cdm_database_schema
@cdmDatabaseSchema

@target_database_schema
@resultsDatabaseSchema

@target_cohort_table
@outcome_precohort_table

@target_cohort_id
2 (MI)
*/

select row_number() over (order by P.person_id, P.start_date) as event_id, P.person_id, P.start_date, P.end_date, OP.observation_period_start_date as op_start_date, OP.observation_period_end_date as op_end_date
INTO #primary_events
FROM
(
  select P.person_id, P.start_date, P.end_date, ROW_NUMBER() OVER (PARTITION BY person_id ORDER BY start_date ASC) ordinal
  FROM 
  (
  select C.person_id, C.condition_start_date as start_date, COALESCE(C.condition_end_date, DATEADD(day,1,C.condition_start_date)) as end_date, C.CONDITION_CONCEPT_ID as TARGET_CONCEPT_ID
from 
(
        select co.*, ROW_NUMBER() over (PARTITION BY co.person_id ORDER BY co.condition_start_date) as ordinal
        FROM @cdmDatabaseSchema.CONDITION_OCCURRENCE co
where co.condition_concept_id in (SELECT concept_id from  #Codesets where codeset_id = 4)
) C
JOIN @cdmDatabaseSchema.VISIT_OCCURRENCE V on C.visit_occurrence_id = V.visit_occurrence_id and C.person_id = V.person_id
WHERE V.visit_concept_id in (9201,9203)

  ) P
) P
JOIN @cdmDatabaseSchema.observation_period OP on P.person_id = OP.person_id and P.start_date between OP.observation_period_start_date and op.observation_period_end_date
WHERE DATEADD(day,180,OP.OBSERVATION_PERIOD_START_DATE) <= P.START_DATE AND DATEADD(day,180,P.START_DATE) <= OP.OBSERVATION_PERIOD_END_DATE AND P.ordinal = 1
;


SELECT event_id, person_id, start_date, end_date, op_start_date, op_end_date
INTO #qualified_events
FROM 
(
  select pe.event_id, pe.person_id, pe.start_date, pe.end_date, pe.op_start_date, pe.op_end_date, row_number() over (partition by pe.person_id order by pe.start_date ASC) as ordinal
  FROM #primary_events pe
  
JOIN (
select 0 as index_id, event_id
FROM
(
  select event_id FROM
  (
    SELECT 0 as index_id, p.event_id
FROM #primary_events P
LEFT JOIN
(
  select C.person_id, C.condition_start_date as start_date, COALESCE(C.condition_end_date, DATEADD(day,1,C.condition_start_date)) as end_date, C.CONDITION_CONCEPT_ID as TARGET_CONCEPT_ID
from 
(
        select co.*, ROW_NUMBER() over (PARTITION BY co.person_id ORDER BY co.condition_start_date) as ordinal
        FROM @cdmDatabaseSchema.CONDITION_OCCURRENCE co
where co.condition_concept_id in (SELECT concept_id from  #Codesets where codeset_id = 10)
) C



) A on A.person_id = P.person_id and A.START_DATE >= P.OP_START_DATE AND A.START_DATE <= P.OP_END_DATE AND A.START_DATE >= P.OP_START_DATE and A.START_DATE <= DATEADD(day,0,P.START_DATE)
GROUP BY p.event_id
HAVING COUNT(A.TARGET_CONCEPT_ID) >= 1


  ) CQ
  GROUP BY event_id
  HAVING COUNT(index_id) = 1
) G
) AC on AC.event_id = pe.event_id

) QE
WHERE QE.ordinal = 1
;


create table #inclusionRuleCohorts 
(
  inclusion_rule_id bigint,
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
    LEFT JOIN #inclusionRuleCohorts I on I.event_id = Q.event_id
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



DELETE FROM #precohort where cohort_definition_id = 2;
INSERT INTO #precohort (cohort_definition_id, subject_id, cohort_start_date, cohort_end_date)
select 2 as cohort_definition_id, F.person_id, F.start_date, F.end_date
FROM (
  select Q.person_id, Q.start_date, E.end_date, row_number() over (partition by Q.event_id order by E.end_date) as ordinal 
  from #qualified_events Q
  join #cohort_ends E on Q.event_id = E.event_id and Q.person_id = E.person_id and E.end_date >= Q.start_date
) F
WHERE F.ordinal = 1
;




TRUNCATE TABLE #cohort_ends;
DROP TABLE #cohort_ends;

TRUNCATE TABLE #inclusionRuleCohorts;
DROP TABLE #inclusionRuleCohorts;

TRUNCATE TABLE #qualified_events;
DROP TABLE #qualified_events;

TRUNCATE TABLE #included_events;
DROP TABLE #included_events;

TRUNCATE TABLE #primary_events;
DROP TABLE #primary_events;

--MI cohort end------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------
--HF cohort start-----------------------------------------------------------------------------------------------
/*
@cdm_database_schema
@cdmDatabaseSchema

@target_database_schema
@resultsDatabaseSchema

@target_cohort_table
@outcome_precohort_table

@target_cohort_id
3 (HF)
*/

select row_number() over (order by P.person_id, P.start_date) as event_id, P.person_id, P.start_date, P.end_date, OP.observation_period_start_date as op_start_date, OP.observation_period_end_date as op_end_date
INTO #primary_events
FROM
(
  select P.person_id, P.start_date, P.end_date, ROW_NUMBER() OVER (PARTITION BY person_id ORDER BY start_date ASC) ordinal
  FROM 
  (
  select C.person_id, C.condition_start_date as start_date, COALESCE(C.condition_end_date, DATEADD(day,1,C.condition_start_date)) as end_date, C.CONDITION_CONCEPT_ID as TARGET_CONCEPT_ID
from 
(
        select co.*, ROW_NUMBER() over (PARTITION BY co.person_id ORDER BY co.condition_start_date) as ordinal
        FROM @cdmDatabaseSchema.CONDITION_OCCURRENCE co
where co.condition_concept_id in (SELECT concept_id from  #Codesets where codeset_id = 9)
) C
JOIN @cdmDatabaseSchema.VISIT_OCCURRENCE V on C.visit_occurrence_id = V.visit_occurrence_id and C.person_id = V.person_id
WHERE V.visit_concept_id in (9201,9203)

  ) P
) P
JOIN @cdmDatabaseSchema.observation_period OP on P.person_id = OP.person_id and P.start_date between OP.observation_period_start_date and op.observation_period_end_date
WHERE DATEADD(day,180,OP.OBSERVATION_PERIOD_START_DATE) <= P.START_DATE AND DATEADD(day,180,P.START_DATE) <= OP.OBSERVATION_PERIOD_END_DATE AND P.ordinal = 1
;


SELECT event_id, person_id, start_date, end_date, op_start_date, op_end_date
INTO #qualified_events
FROM 
(
  select pe.event_id, pe.person_id, pe.start_date, pe.end_date, pe.op_start_date, pe.op_end_date, row_number() over (partition by pe.person_id order by pe.start_date ASC) as ordinal
  FROM #primary_events pe
  
JOIN (
select 0 as index_id, event_id
FROM
(
  select event_id FROM
  (
    SELECT 0 as index_id, p.event_id
FROM #primary_events P
LEFT JOIN
(
  select C.person_id, C.condition_start_date as start_date, COALESCE(C.condition_end_date, DATEADD(day,1,C.condition_start_date)) as end_date, C.CONDITION_CONCEPT_ID as TARGET_CONCEPT_ID
from 
(
        select co.*, ROW_NUMBER() over (PARTITION BY co.person_id ORDER BY co.condition_start_date) as ordinal
        FROM @cdmDatabaseSchema.CONDITION_OCCURRENCE co
where co.condition_concept_id in (SELECT concept_id from  #Codesets where codeset_id = 10)
) C



) A on A.person_id = P.person_id and A.START_DATE >= P.OP_START_DATE AND A.START_DATE <= P.OP_END_DATE AND A.START_DATE >= P.OP_START_DATE and A.START_DATE <= DATEADD(day,0,P.START_DATE)
GROUP BY p.event_id
HAVING COUNT(A.TARGET_CONCEPT_ID) >= 1


  ) CQ
  GROUP BY event_id
  HAVING COUNT(index_id) = 1
) G
) AC on AC.event_id = pe.event_id

) QE
WHERE QE.ordinal = 1
;


create table #inclusionRuleCohorts 
(
  inclusion_rule_id bigint,
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
    LEFT JOIN #inclusionRuleCohorts I on I.event_id = Q.event_id
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



DELETE FROM #precohort where cohort_definition_id = 3;
INSERT INTO #precohort (cohort_definition_id, subject_id, cohort_start_date, cohort_end_date)
select 3 as cohort_definition_id, F.person_id, F.start_date, F.end_date
FROM (
  select Q.person_id, Q.start_date, E.end_date, row_number() over (partition by Q.event_id order by E.end_date) as ordinal 
  from #qualified_events Q
  join #cohort_ends E on Q.event_id = E.event_id and Q.person_id = E.person_id and E.end_date >= Q.start_date
) F
WHERE F.ordinal = 1
;




TRUNCATE TABLE #cohort_ends;
DROP TABLE #cohort_ends;

TRUNCATE TABLE #inclusionRuleCohorts;
DROP TABLE #inclusionRuleCohorts;

TRUNCATE TABLE #qualified_events;
DROP TABLE #qualified_events;

TRUNCATE TABLE #included_events;
DROP TABLE #included_events;

TRUNCATE TABLE #primary_events;
DROP TABLE #primary_events;

--HF cohort end-----------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------


---------------------------------------------------------------------------------------------------------------------------
--stroke cohort start-----------------------------------------------------------------------------------------------------

/*
@cdm_database_schema
@cdmDatabaseSchema

@target_database_schema
@resultsDatabaseSchema

@target_cohort_table
@outcome_precohort_table

@target_cohort_id
4 (stroke)
*/

select row_number() over (order by P.person_id, P.start_date) as event_id, P.person_id, P.start_date, P.end_date, OP.observation_period_start_date as op_start_date, OP.observation_period_end_date as op_end_date
INTO #primary_events
FROM
(
  select P.person_id, P.start_date, P.end_date, ROW_NUMBER() OVER (PARTITION BY person_id ORDER BY start_date ASC) ordinal
  FROM 
  (
  select C.person_id, C.condition_start_date as start_date, COALESCE(C.condition_end_date, DATEADD(day,1,C.condition_start_date)) as end_date, C.CONDITION_CONCEPT_ID as TARGET_CONCEPT_ID
from 
(
        select co.*, ROW_NUMBER() over (PARTITION BY co.person_id ORDER BY co.condition_start_date) as ordinal
        FROM @cdmDatabaseSchema.CONDITION_OCCURRENCE co
where co.condition_concept_id in (SELECT concept_id from  #Codesets where codeset_id = 6)
) C
JOIN @cdmDatabaseSchema.VISIT_OCCURRENCE V on C.visit_occurrence_id = V.visit_occurrence_id and C.person_id = V.person_id
WHERE V.visit_concept_id in (9201,9203)

  ) P
) P
JOIN @cdmDatabaseSchema.observation_period OP on P.person_id = OP.person_id and P.start_date between OP.observation_period_start_date and op.observation_period_end_date
WHERE DATEADD(day,180,OP.OBSERVATION_PERIOD_START_DATE) <= P.START_DATE AND DATEADD(day,180,P.START_DATE) <= OP.OBSERVATION_PERIOD_END_DATE AND P.ordinal = 1
;


SELECT event_id, person_id, start_date, end_date, op_start_date, op_end_date
INTO #qualified_events
FROM 
(
  select pe.event_id, pe.person_id, pe.start_date, pe.end_date, pe.op_start_date, pe.op_end_date, row_number() over (partition by pe.person_id order by pe.start_date ASC) as ordinal
  FROM #primary_events pe
  
JOIN (
select 0 as index_id, event_id
FROM
(
  select event_id FROM
  (
    SELECT 0 as index_id, p.event_id
FROM #primary_events P
LEFT JOIN
(
  select C.person_id, C.condition_start_date as start_date, COALESCE(C.condition_end_date, DATEADD(day,1,C.condition_start_date)) as end_date, C.CONDITION_CONCEPT_ID as TARGET_CONCEPT_ID
from 
(
        select co.*, ROW_NUMBER() over (PARTITION BY co.person_id ORDER BY co.condition_start_date) as ordinal
        FROM @cdmDatabaseSchema.CONDITION_OCCURRENCE co
where co.condition_concept_id in (SELECT concept_id from  #Codesets where codeset_id = 10)
) C



) A on A.person_id = P.person_id and A.START_DATE >= P.OP_START_DATE AND A.START_DATE <= P.OP_END_DATE AND A.START_DATE >= P.OP_START_DATE and A.START_DATE <= DATEADD(day,0,P.START_DATE)
GROUP BY p.event_id
HAVING COUNT(A.TARGET_CONCEPT_ID) >= 1


  ) CQ
  GROUP BY event_id
  HAVING COUNT(index_id) = 1
) G
) AC on AC.event_id = pe.event_id

) QE
WHERE QE.ordinal = 1
;


create table #inclusionRuleCohorts 
(
  inclusion_rule_id bigint,
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
    LEFT JOIN #inclusionRuleCohorts I on I.event_id = Q.event_id
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



DELETE FROM #precohort where cohort_definition_id = 4;
INSERT INTO #precohort (cohort_definition_id, subject_id, cohort_start_date, cohort_end_date)
select 4 as cohort_definition_id, F.person_id, F.start_date, F.end_date
FROM (
  select Q.person_id, Q.start_date, E.end_date, row_number() over (partition by Q.event_id order by E.end_date) as ordinal 
  from #qualified_events Q
  join #cohort_ends E on Q.event_id = E.event_id and Q.person_id = E.person_id and E.end_date >= Q.start_date
) F
WHERE F.ordinal = 1
;




TRUNCATE TABLE #cohort_ends;
DROP TABLE #cohort_ends;

TRUNCATE TABLE #inclusionRuleCohorts;
DROP TABLE #inclusionRuleCohorts;

TRUNCATE TABLE #qualified_events;
DROP TABLE #qualified_events;

TRUNCATE TABLE #included_events;
DROP TABLE #included_events;

TRUNCATE TABLE #primary_events;
DROP TABLE #primary_events;

TRUNCATE TABLE #codesets;
DROP TABLE #codesets;

--stroke cohort end-------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------

--making composite endpoint cohort
-- This syntax cannot be translated:
--IF OBJECT_ID('@resultsDatabaseSchema.@outcomeTable', 'U') IS NULL



--HF+MI+STROKE+Any DEATH : 4320
DELETE FROM @resultsDatabaseSchema.@outcomeTable WHERE cohort_definition_id = 4320;

INSERT INTO @resultsDatabaseSchema.@outcomeTable
SELECT 4320 AS cohort_definition_id, subject_id, min(cohort_start_date) as cohort_start_date, max(cohort_end_date) as cohort_end_date
FROM #precohort
	WHERE COHORT_DEFINITION_ID = 0
	   OR COHORT_DEFINITION_ID = 2
	   OR COHORT_DEFINITION_ID = 3
	   OR COHORT_DEFINITION_ID = 4
GROUP BY SUBJECT_ID;

--HF+MI+STROKE+Cardiovascular DEATH : 4321
DELETE FROM @resultsDatabaseSchema.@outcomeTable WHERE cohort_definition_id = 4321;

INSERT INTO @resultsDatabaseSchema.@outcomeTable
SELECT 4321 AS cohort_definition_id, subject_id, min(cohort_start_date) as cohort_start_date, max(cohort_end_date) as cohort_end_date
FROM #precohort
	WHERE COHORT_DEFINITION_ID = 1
	   OR COHORT_DEFINITION_ID = 2
	   OR COHORT_DEFINITION_ID = 3
	   OR COHORT_DEFINITION_ID = 4
GROUP BY SUBJECT_ID;



--MI+STROKE+any DEATH : 420
DELETE FROM @resultsDatabaseSchema.@outcomeTable WHERE cohort_definition_id = 420

INSERT INTO @resultsDatabaseSchema.@outcomeTable
SELECT 420 AS cohort_definition_id, subject_id, min(cohort_start_date) as cohort_start_date, max(cohort_end_date) as cohort_end_date
FROM #precohort
	WHERE COHORT_DEFINITION_ID = 0
	   OR COHORT_DEFINITION_ID = 2
	   OR COHORT_DEFINITION_ID = 4
GROUP BY SUBJECT_ID;

--MI+STROKE+cardio cerebral DEATH : 421
DELETE FROM @resultsDatabaseSchema.@outcomeTable WHERE cohort_definition_id = 421

INSERT INTO @resultsDatabaseSchema.@outcomeTable
SELECT 421 AS cohort_definition_id, subject_id, min(cohort_start_date) as cohort_start_date, max(cohort_end_date) as cohort_end_date
FROM #precohort
	WHERE COHORT_DEFINITION_ID = 1
	   OR COHORT_DEFINITION_ID = 2
	   OR COHORT_DEFINITION_ID = 4
GROUP BY SUBJECT_ID;

--Any death : 0
DELETE FROM @resultsDatabaseSchema.@outcomeTable WHERE cohort_definition_id = 0

INSERT INTO @resultsDatabaseSchema.@outcomeTable
SELECT 0 AS cohort_definition_id, subject_id, min(cohort_start_date) as cohort_start_date, max(cohort_end_date) as cohort_end_date
FROM #precohort
	WHERE COHORT_DEFINITION_ID = 0
GROUP BY SUBJECT_ID;

--Cardio-cerebral death : 1
DELETE FROM @resultsDatabaseSchema.@outcomeTable WHERE cohort_definition_id = 1

INSERT INTO @resultsDatabaseSchema.@outcomeTable
SELECT 1 AS cohort_definition_id, subject_id, min(cohort_start_date) as cohort_start_date, max(cohort_end_date) as cohort_end_date
FROM #precohort
	WHERE COHORT_DEFINITION_ID = 1
GROUP BY SUBJECT_ID;


--MI : 2
DELETE FROM @resultsDatabaseSchema.@outcomeTable WHERE cohort_definition_id = 2

INSERT INTO @resultsDatabaseSchema.@outcomeTable
SELECT 2 AS cohort_definition_id, subject_id, min(cohort_start_date) as cohort_start_date, max(cohort_end_date) as cohort_end_date
FROM #precohort
	WHERE COHORT_DEFINITION_ID = 2
GROUP BY SUBJECT_ID;

--HF : 3
DELETE FROM @resultsDatabaseSchema.@outcomeTable WHERE cohort_definition_id = 3

INSERT INTO @resultsDatabaseSchema.@outcomeTable
SELECT 3 AS cohort_definition_id, subject_id, min(cohort_start_date) as cohort_start_date, max(cohort_end_date) as cohort_end_date
FROM #precohort
	WHERE COHORT_DEFINITION_ID = 3
GROUP BY SUBJECT_ID;

--STROKE : 4
DELETE FROM @resultsDatabaseSchema.@outcomeTable WHERE cohort_definition_id = 4

INSERT INTO @resultsDatabaseSchema.@outcomeTable
SELECT 4 AS cohort_definition_id, subject_id, min(cohort_start_date) as cohort_start_date, max(cohort_end_date) as cohort_end_date
FROM #precohort
	WHERE COHORT_DEFINITION_ID = 4
GROUP BY SUBJECT_ID;


TRUNCATE TABLE #precohort;
DROP TABLE #precohort;
