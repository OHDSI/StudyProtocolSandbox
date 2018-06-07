Themis group (sub-group: measurements) aims to standardize lab tests and related issues (e.g., units)

# Introduction
This effort will be based on real world data at OHDSI sites.

## Update 2018-05

Slight update to the data collected for ThemisMeasurement Database (looks at Measurements and Observations). Achilles Heel implementation discussion. Posting of units results.

## Update 2018-02

The result of the network study is ThemisUnits database (or knowledge base) (and other knowledge bases also looking at measurements (without regard to units)
JAMIA Open allows publishing short article centered about database. Outcomes will be published under this framework (as ThemisUnits database)  

## Update 2018-01
Partial interim themis study results can be found at https://github.com/OHDSI/StudyProtocolSandbox/tree/master/themis/extras/partial_results


# Execution details
Consider installing Arachne and run and submit the results in Arachne (preferred)
Alternatively, use Non-Arachne method.



# Arachne execution
To test SQL based Arachne study, use this study to test the framework: https://www.arachnenetwork.com/study-manager/studies/46

# Non-Arachne execution


## R package
Themis study is not yet fully implemented using R package. Only isolated pieces of code exist in the R subfolder. The core of the study is in the section 'plain SQL'.


### miad.R
This file is optional to run. See separate miad.md file for descriptions of what it is.

## Plain SQL


Execute the following SQL and email the resulting CSV to the themis group representative for a given convention issue (vojtech.huser at nih dot gov for measurement analysis)
Name your CSV file with meaningless numerical 3 digit ID for your dataset (e.g., 147) followed by dash and name of analysis(which also may have dashes in the name (all lowercase)). (e.g., 147-measurements-concepts.csv and 147-units-larger.csv). Note that your chosen anonymous dataset ID will remain the same for all exported files. Please make sure you use a standard .csv file (which can be read by R's read.csv or read_csv). If you have multiple datasets to analyze, simply repeat the process for the second or third dataset chosing a different dataset ID.

SQL is optimized to work in result schema. (written in specific dialect so some tweaking may be necessary)
Email me is you need parametized SQL for this translation tool. http://data.ohdsi.org/SqlDeveloper/. In fact a draft of the parametized SQL is being created in the other folder but untill fuly finished, use the SQL code in this document.

### measurements-concepts

```SQL
    select * from (select analysis_id, stratum_1,count_value from achilles_results where analysis_id = 1800 and count_value > 500 order by count_value desc limit 300) a
    union
    select * from (select analysis_id, stratum_1,count_value from achilles_results where analysis_id = 800 and count_value > 500 order by count_value desc limit 300) b
```


### units-larger

As you explore the SQL, you can turn on the commented out columns to better understand the exported data. Centralized processing with work even if you leave the concept name columns in the query and export tham in the CSV (as long as you don't change column names for key columns needed by centralized processing.

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
  --and e.stratum_2 <> '0' --exclude data where unit is not mapped to a formal concept
  and s.denom > 500 --minumum number of rows for a test to be included, tweak this up to reduce the size of shared data
order by e.stratum_1, count_value desc
;
```


### Unit Results

Units poster at 2017 OHDSI symposium: http://www.ohdsi.org/web/wiki/lib/exe/fetch.php?media=resources:huser-2017-ohdsi-symp-units.pdf


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



# Centralized processing

Each extracted data is compared accross several sites. That way we can arrive at common measurements and common units for them accross the network.

# Existing Achilles Heel infrustructure

Look at analysis_id 1900 to see your local unmapped source_values for Measurements.
Weight is subject to the existing Heel rule. LOINC concept is being targeted.
