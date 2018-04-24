select * from (
    select * from (select top 200 analysis_id, stratum_1 from achilles_results where analysis_id = 1800 and count_value > 500 order by count_value desc) a
    union
    select * from (select top 200 analysis_id, stratum_1 from achilles_results where analysis_id = 800 and count_value > 500 order by count_value desc) b
    ) c