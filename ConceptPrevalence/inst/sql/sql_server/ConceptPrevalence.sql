/************************************************************************
@file ConceptPrevalence.sql
Copyright 2018 Observational Health Data Sciences and Informatics
This file is part of CohortMethod
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
************************************************************************/

{DEFAULT @cdm_database_schema = 'CDM_SIM' }
{DEFAULT @vocabulary_database_schema = 'CDM_SIM' }
{DEFAULT @cdm_name = 'CDM' }
{DEFAULT @target_database_schema = 'CDM_SIM'}

IF OBJECT_ID('@target_database_schema.count_standard', 'U') IS NOT NULL
DROP TABLE @target_database_schema.count_standard;

create table @target_database_schema.count_standard
(
concept_id int,
cnt int,
type varchar (255)
);

insert into @target_database_schema.count_standard
-- demographic
select gender_concept_id,count(*) as cnt, 'gender' as type
from @cdm_database_schema.person
group by gender_concept_id
union all
select race_concept_id, count(*) as cnt, 'race' 
from @cdm_database_schema.person
group by race_concept_id
union all
select ethnicity_concept_id, count(*),'ethnicity'
from @cdm_database_schema.person
group by ethnicity_concept_id
--clinical
union all
select drug_concept_id, count(*),'drug'
from @cdm_database_schema.drug_exposure
group by drug_concept_id
union all
select device_concept_id, count(*),'device'
from @cdm_database_schema.device_exposure
group by device_concept_id
union all
select observation_concept_id, count(*),'observation'
from @cdm_database_schema.observation
group by observation_concept_id
union all
select procedure_concept_id, count(*),'procedure'
from @cdm_database_schema.procedure_occurrence
group by procedure_concept_id
union all
select condition_concept_id, count(*),'condition'
from @cdm_database_schema.condition_occurrence
group by condition_concept_id
union all
select measurement_concept_id, count(*),'measurement'
from @cdm_database_schema.measurement
group by measurement_concept_id
union all
select specimen_concept_id, count(*),'specimen'
from @cdm_database_schema.specimen
group by specimen_concept_id
union all
--economics
--select cost_concept_id, count(*),'cost'
--from @cdm_database_schema.cost
--group by cost_concept_id
--union all
select visit_type_concept_id, count(*),'visit'
from @cdm_database_schema.visit_occurrence
group by visit_type_concept_id
union all
select place_of_service_concept_id, count(*), 'place of service'
from @cdm_database_schema.care_site
group by place_of_service_concept_id
union all
select specialty_concept_id, count(*), 'specialty'
from @cdm_database_schema.provider
group by specialty_concept_id;


IF OBJECT_ID('@target_database_schema.count_source', 'U') IS NOT NULL
DROP TABLE @target_database_schema.count_source;

create table @target_database_schema.count_source
(
concept_id int,
cnt int,
type varchar (255)    
);

insert into @target_database_schema.count_source
-- demographic
select gender_source_concept_id,count(*) as cnt, 'gender' as type
from @cdm_database_schema.person
group by gender_source_concept_id
union all
select race_source_concept_id, count(*) , 'race' 
from @cdm_database_schema.person
group by race_source_concept_id
union all
select ethnicity_source_concept_id, count(*),'ethnicity'
from @cdm_database_schema.person
group by ethnicity_source_concept_id
--clinical
union all
select drug_source_concept_id, count(*),'drug'
from @cdm_database_schema.drug_exposure
group by drug_source_concept_id
union all
select device_source_concept_id, count(*),'device'
from @cdm_database_schema.device_exposure
group by device_source_concept_id
union all
select observation_source_concept_id, count(*),'observation'
from @cdm_database_schema.observation
group by observation_source_concept_id
union all
select procedure_source_concept_id, count(*),'procedure'
from @cdm_database_schema.procedure_occurrence
group by procedure_source_concept_id
union all
select condition_source_concept_id, count(*),'condition'
from @cdm_database_schema.condition_occurrence
group by condition_source_concept_id
union all
select measurement_source_concept_id, count(*),'measurement'
from @cdm_database_schema.measurement
group by measurement_source_concept_id
;

IF OBJECT_ID('@target_database_schema.mappings', 'U') IS NOT NULL
DROP TABLE @target_database_schema.mappings;

create table @target_database_schema.mappings
(
concept_id_1 int,
relationship_id varchar (255),
concept_id_2 int
);

insert into @target_database_schema.mappings
select concept_id_1, relationship_id, concept_id_2
from @vocabulary_database_schema.concept_relationship
where relationship_id in ('Maps to', 'Maps to value');

IF OBJECT_ID('@target_database_schema.cdm_vocab_version', 'U') IS NOT NULL
DROP TABLE @target_database_schema.cdm_vocab_version;

create table @target_database_schema.cdm_vocab_version
(vocabulary_id varchar (255),
 vocabulary_version varchar (255)
);

insert into @target_database_schema.cdm_vocab_version
select vocabulary_id,vocabulary_version
from @vocabulary_database_schema.vocabulary;

IF OBJECT_ID('@target_database_schema.cdm', 'U') IS NOT NULL
DROP TABLE @target_database_schema.cdm;

create table @target_database_schema.cdm
(
 patient_cnt int,
 cdm_name varchar (255),
 start_date date,
 end_date date
);

insert into @target_database_schema.cdm
select count(p.person_id) as patient_cnt, '@cdm_name' as cdm_name, min(observation_period_start_date) as start_date,max(observation_period_end_date) as end_date
from @cdm_database_schema.person p
left join @cdm_database_schema.observation_period o on p.person_id = o.person_id;

