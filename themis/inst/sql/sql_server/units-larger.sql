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