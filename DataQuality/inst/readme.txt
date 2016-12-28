This file describes individual files included in the DataQuality export folder/export zip file.




.png
====
files are plots generated from data. Some plots have an associated CSV file that contains the 
data used by the plot


HeelOutput.csv
==============
Listing of all Heel errors. Errors with row_count under 10 are not exported (privacy preserving principle)


SelectedDerivedMeasures.csv
===========================
Heel SQL file generates an additional table with derived measures. This file lists those derived measures.
Measures are identified by measure_id. This is a text ID (unlike analysis_id which is a number). String 
ID was suggested by Data Quality Collaborative team.


SelectedAchillesResults*.csv
============================
Set of multiple files. They contain a subset of Achilles Analyses (those that are not sensitive
to share). 
___Perc.csv
For measures that are patient counts, those are in file __Perc.csv where the counts
are replaced with % of the total count of patients.  Analysis_id 99 outputs the size-category
of the dataset. (e.g., <5M means dataset is between 1M-4M). Exact size in masked (privacy 
preserving princple)
___DistMeasures.csv
This file  contains data from the ACHILLES_RESULTS_DIST table. Such analyses 
are numerical analyses with percentiles. 



Additional files may be present, which indicates that this readme file was not kept 100% current.
However, the file name should clearly indicate what data is inside it.