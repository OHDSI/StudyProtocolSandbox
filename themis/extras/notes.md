Themis group (sub-group: measurements) aims to standardize lab tests and related issues (e.g., units)

This effort will be based on real world data at OHDSI sites.
Consider installing Arachne and run and submit the code in Arachne (preferred)
Alternatively, use Non-Arachne method.



# Arachne execution
To test SQL based Arachne study, use this study to test the framework: https://www.arachnenetwork.com/study-manager/studies/46

# Non-Arachne execution

## Plain SQL


Execute the following SQL and email the resulting CSV to themis group reprentative for a given convention issue (vojtech.huser at nih dot gov )
Name your CSV file with meaningless numerical 3 ditit ID for your site followed by dash and name of analysis. (e.g., 147-units-limited.csv)

SQL is optimized to work in result schema. (written in specific dialect so some tweaking may be necessary)
Email me is you need parametized SQL for this translation tool. http://data.ohdsi.org/SqlDeveloper/

### Measurements-concepts

```SQL
select * from (
    select * from (select analysis_id, stratum_1 from achilles_results where analysis_id = 1800 and count_value > 1000 order by count_value desc limit 100) a
    union
    select * from (select analysis_id, stratum_1 from achilles_results where analysis_id = 800 and count_value > 1000 order by count_value desc limit 100) b
) c
--order by stratum_1; --uncomment the last line to not to reveal ranking order of your concepts
```

### Units-limited
```SQL
select e.analysis_id,e.stratum_1 as concept_id,e.stratum_2 as unit_concept_id,
1.0*count_value/denom as ratio
--,count_value,denom   --comment this back in to see absolute numbers
--,c1.concept_name,c2.concept_name as unit_name
from achilles_results e 
join --query below is to compute totals for each stratum
  (select e.analysis_id,e.stratum_1,sum(count_value) as denom from achilles_results e where analysis_id in (1807) group by e.analysis_id,e.stratum_1) s 
    on e.analysis_id = s.analysis_id and e.stratum_1 = s.stratum_1
--join public.concept c1 on cast(e.stratum_1 as int) = c1.concept_id  
--join public.concept c2 on cast(e.stratum_2 as int) = c2.concept_id 
where e.analysis_id in (1807) 
  and 1.0*count_value/denom <= 0.95 --measurements with just one major unit are excluded to minimize the sharing
  and 1.0*count_value/denom >= 0.10 --smaller ratio rows are not included in the extract
  and e.stratum_2 <> '0' --exclude data where unit is not mapped to a formal concept
  and s.denom > 1000 --minumum number of rows for a test to be included, tweak this up to reduce the size of shared data
order by e.stratum_1, count_value desc
;
```

### Units-larger
```SQL
select e.analysis_id,e.stratum_1 as concept_id,e.stratum_2 as unit_concept_id,
1.0*count_value/denom as ratio
--,count_value,denom   --comment this back in to see absolute numbers
--,c1.concept_name,c2.concept_name as unit_name
from achilles_results e 
join --query below is to compute totals for each stratum
  (select e.analysis_id,e.stratum_1,sum(count_value) as denom from achilles_results e where analysis_id in (1807) group by e.analysis_id,e.stratum_1) s 
    on e.analysis_id = s.analysis_id and e.stratum_1 = s.stratum_1
--join public.concept c1 on cast(e.stratum_1 as int) = c1.concept_id  
--join public.concept c2 on cast(e.stratum_2 as int) = c2.concept_id 
where e.analysis_id in (1807) 
  and 1.0*count_value/denom <= 1.0 --measurements with just one major unit are excluded to minimize the sharing
  and 1.0*count_value/denom >= 0.02 --smaller ratio rows are not included in the extract
  and e.stratum_2 <> '0' --exclude data where unit is not mapped to a formal concept
  and s.denom > 500 --minumum number of rows for a test to be included, tweak this up to reduce the size of shared data
order by e.stratum_1, count_value desc
;
```


### Unit Results

Units poster at 2017 OHDSI symposium: http://www.ohdsi.org/web/wiki/lib/exe/fetch.php?media=resources:huser-2017-ohdsi-symp-units.pdf

## R package


# General notes

measurements in PCORNet
http://pcornet.org/wp-content/uploads/2017/05/2017-05-01_Integrated-CDM-Specification-Implemeantion-Guidance-CDM-v....pdf

```
A1C=Hemoglobin A1c
CK=Creatine kinase total
CK_MB=Creatine kinase MB
CK_MBI=Creatine kinase
MB/creatine kinase total
CREATININE=Creatinine
HGB=Hemoglobin
LDL=Low-density lipoprotein
INR=International normalized ratio
TROP_I=Troponin I cardiac
TROP_T_QL=Troponin T cardiac (qualitative)
TROP_T_QN=Troponin T cardiac (quantitative)
NI=No information
UN=Unknown
OT=Other
```
