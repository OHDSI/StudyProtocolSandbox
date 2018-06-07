INSERT INTO @resultsDatabaseSchema.@outcomeTable (cohort_definition_id, cohort_start_date, cohort_end_date, subject_id)
SELECT ancestor_concept_id AS cohort_definition_id,
condition_start_date AS cohort_start_date,
condition_start_date AS cohort_end_date,
condition_occurrence.person_id AS subject_id
FROM @cdmDatabaseSchema.condition_occurrence
INNER JOIN @cdmDatabaseSchema.visit_occurrence
ON condition_occurrence.visit_occurrence_id = visit_occurrence.visit_occurrence_id
INNER JOIN @cdmDatabaseSchema.concept_ancestor
ON condition_concept_id = descendant_concept_id
WHERE ancestor_concept_id IN (378424, 4004352, 4280726, 133141, 137053, 140480, 380731,
381581, 75344,  80809, 376415,  4224118, 4253054, 437409, 199067, 434272, 373478, 140641, 139099,
4142905, 195862, 4271016, 375552, 380038, 135473, 138102, 29735, 4153877, 74396, 134870, 74855,
200169, 194997,  192367, 4267582, 434872, 4329707, 4288544, 198075);