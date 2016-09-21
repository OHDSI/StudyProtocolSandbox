
--Declare the DB name 
USE [DB name]

--Make disease concept_ID table for inclusion and exclusion of SCA
SELECT X.*
INTO #disease
FROM
	(SELECT CONCEPT_ID AS CONCEPT_ID, disease = 'SCA', criteria = 'in'
	FROM CONCEPT
	WHERE CONCEPT_ID IN
		(SELECT DESCENDANT_CONCEPT_ID
		FROM [dbo].[CONCEPT_ANCESTOR]
		WHERE ANCESTOR_CONCEPT_ID = 321042)
		AND CONCEPT_ID NOT IN (4269927, 4122762, 4119604, 4041343, 4306984, 43530960, 4111700, 4173792, 4173446, 4311273, 4148028 )  --Cardiac arrest concept_ID
	
	UNION ALL 

	SELECT DESCENDANT_CONCEPT_ID  AS CONCEPT_ID , disease = 'SCA', criteria = 'in'
	FROM CONCEPT_ANCESTOR
	WHERE ANCESTOR_CONCEPT_ID IN 
		(SELECT CONCEPT_ID FROM CONCEPT
		WHERE VOCABULARY_ID = 'SNOMED'
		AND	CONCEPT_NAME = 'Malignant neoplastic disease'
		AND STANDARD_CONCEPT = 'S')

	UNION ALL
	
	SELECT DESCENDANT_CONCEPT_ID AS CONCEPT_ID, disease = 'ICH', criteria = 'out'
	FROM CONCEPT_ANCESTOR
	WHERE ANCESTOR_CONCEPT_ID IN 
		(SELECT CONCEPT_ID FROM CONCEPT
		WHERE VOCABULARY_ID = 'SNOMED'
		AND	CONCEPT_NAME = 'Intracranial hemorrhage'
		AND STANDARD_CONCEPT = 'S')

	UNION ALL
	
	SELECT DESCENDANT_CONCEPT_ID AS CONCEPT_ID, disease = 'injury', criteria = 'out'
	FROM CONCEPT_ANCESTOR
	WHERE ANCESTOR_CONCEPT_ID IN 
		(SELECT CONCEPT_ID FROM CONCEPT
		WHERE VOCABULARY_ID = 'SNOMED'
		AND	CONCEPT_NAME = 'Traumatic AND/OR non-traumatic injury'
		AND STANDARD_CONCEPT = 'S')

	UNION ALL
	
	SELECT DESCENDANT_CONCEPT_ID AS CONCEPT_ID, disease = 'poisoning', criteria = 'out'
	FROM CONCEPT_ANCESTOR
	WHERE ANCESTOR_CONCEPT_ID IN 
		(SELECT CONCEPT_ID FROM CONCEPT
		WHERE VOCABULARY_ID = 'SNOMED'
		AND	CONCEPT_NAME = 'poisoning'
		AND STANDARD_CONCEPT = 'S')

	UNION ALL
	
	SELECT DESCENDANT_CONCEPT_ID AS CONCEPT_ID, disease = 'self_injury', criteria = 'out'
	FROM CONCEPT_ANCESTOR
	WHERE ANCESTOR_CONCEPT_ID IN 
		(SELECT CONCEPT_ID FROM CONCEPT
		WHERE VOCABULARY_ID = 'SNOMED'
		AND	CONCEPT_NAME = 'Self-injurious behavior'
		AND STANDARD_CONCEPT = 'S')

	UNION ALL

	SELECT DESCENDANT_CONCEPT_ID AS CONCEPT_ID, disease = 'cancer', criteria = 'out'
	FROM CONCEPT_ANCESTOR
	WHERE ANCESTOR_CONCEPT_ID IN 
		(SELECT CONCEPT_ID FROM CONCEPT
		WHERE VOCABULARY_ID = 'SNOMED'
		AND	CONCEPT_NAME = 'Malignant neoplastic disease'
		AND STANDARD_CONCEPT = 'S')

	) X


IF OBJECT_ID('temp_SCApt_1', 'U') IS NOT NULL
	DROP TABLE temp_SCApt_1;

--Selection patient with SCA and ER visit
SELECT a.person_id, MIN(CAST(a.condition_start_date AS DATE)) as sca_date, 
				  MIN(CAST(b.visit_start_date AS DATE)) AS hospital_start , MAX(CAST(b.visit_end_date AS DATE)) AS hospital_end
		INTO temp_SCApt_1
		FROM condition_occurrence a, visit_occurrence b
		WHERE CONDITION_CONCEPT_ID IN (SELECT CONCEPT_ID FROM #disease WHERE criteria = 'IN')
				  and a.person_id=b.person_id
				  and visit_concept_id=9203
				  and CAST(a.condition_start_date AS DATE) between CAST(b.visit_start_date AS DATE) and CAST(b.visit_end_date AS DATE)
		GROUP BY a.person_id


--AGE of patients
SELECT B.person_id,DATEDIFF(YEAR,(CAST (CONCAT (B.year_of_birth ,'-', B.month_of_birth ,'-', B.day_of_birth) AS DATE) ), A.hospital_start) as age
	INTO #SCA_pt_age
	FROM person B
	JOIN temp_SCApt_1 A
	ON A.person_id= B.person_id

ALTER TABLE temp_SCApt_1 ADD age INT 

UPDATE temp_SCApt_1
	SET age = B.age
	FROM temp_SCApt_1 A
		INNER JOIN #SCA_pt_age B
			ON A.person_id = B.person_id

--DELETE patients aged under 15
DELETE temp_SCApt_1 WHERE age<15


--Diagnosis on the same day or after SCA diagnosis as comorbidities
IF OBJECT_ID('temp_SCA_comorb', 'U') IS NOT NULL
	DROP TABLE temp_SCA_comorb;

SELECT DISTINCT A.person_id, A.CONDITION_CONCEPT_ID, A.CONDITION_START_DATE, A.visit_occurrence_id, B.hospital_start, B.hospital_end, B.sca_date
	INTO  temp_SCA_comorb
	FROM CONDITION_OCCURRENCE A
	JOIN temp_SCApt_1 B
	ON A.PERSON_ID = B.PERSON_ID
	WHERE A.condition_start_date >= b.hospital_start

--Find patients who met exclusion criteria
IF OBJECT_ID('excluded_pt', 'U') IS NOT NULL
	DROP TABLE excluded_pt

SELECT DISTINCT PERSON_ID, CONDITION_CONCEPT_ID, CONDITION_START_DATE, hospital_start, sca_date
	INTO excluded_pt
	FROM temp_SCA_comorb
	WHERE condition_concept_id IN
	(SELECT CONCEPT_ID FROM #disease WHERE criteria = 'OUT')
	AND DATEDIFF (DAY,hospital_start,condition_start_date) <=3

--Exclude the patients who diagnosed with exclusion-diagnosis 
IF OBJECT_ID('temp_SCApt_2', 'U') IS NOT NULL
	DROP TABLE temp_SCApt_2

SELECT * 
	INTO temp_SCApt_2
	FROM temp_SCApt_1
	WHERE PERSON_ID NOT IN (SELECT PERSON_ID FROM excluded_pt)

--comorbidity disease listing (into #comorbidity)
SELECT X.*
INTO #comorbidity
FROM 
(
	(SELECT concept_id, concept_name, class = 'IHD'
	FROM CONCEPT
	WHERE CONCEPT_ID IN
		(SELECT DESCENDANT_CONCEPT_ID
		FROM [dbo].[CONCEPT_ANCESTOR]
		WHERE ANCESTOR_CONCEPT_ID IN
			(SELECT CONCEPT_ID FROM CONCEPT
			WHERE VOCABULARY_ID = 'SNOMED'
			AND CONCEPT_NAME ='ischemic heart disease'
			AND STANDARD_CONCEPT = 'S') )
			)
			UNION ALL

	(SELECT concept_id, concept_name, class = 'HF'
	FROM CONCEPT
	WHERE CONCEPT_ID IN
		(SELECT DESCENDANT_CONCEPT_ID
		FROM [dbo].[CONCEPT_ANCESTOR]
		WHERE ANCESTOR_CONCEPT_ID IN
			(SELECT CONCEPT_ID FROM CONCEPT
			WHERE VOCABULARY_ID = 'SNOMED'
			AND CONCEPT_NAME ='heart failure'
			AND STANDARD_CONCEPT = 'S') ) 
			)
			UNION ALL

	(SELECT concept_id, concept_name, class = 'arrhythmia'
	FROM CONCEPT
	WHERE CONCEPT_ID IN
		(SELECT DESCENDANT_CONCEPT_ID
		FROM [dbo].[CONCEPT_ANCESTOR]
		WHERE ANCESTOR_CONCEPT_ID IN
			(SELECT CONCEPT_ID FROM CONCEPT
			WHERE VOCABULARY_ID = 'SNOMED'
			AND CONCEPT_NAME ='cardiac arrhythmia'
			AND STANDARD_CONCEPT = 'S') )
			)
			UNION ALL

	(SELECT concept_id, concept_name, class = 'VHD'
	FROM CONCEPT
	WHERE CONCEPT_ID IN
		(SELECT DESCENDANT_CONCEPT_ID
		FROM [dbo].[CONCEPT_ANCESTOR]
		WHERE ANCESTOR_CONCEPT_ID IN
			(SELECT CONCEPT_ID FROM CONCEPT
			WHERE VOCABULARY_ID = 'SNOMED'
			AND CONCEPT_NAME ='Heart valve disorder'
			AND STANDARD_CONCEPT = 'S') )
			)
			UNION ALL

	(SELECT concept_id, concept_name, class = 'CKD'
	FROM CONCEPT
	WHERE CONCEPT_ID IN
		(SELECT DESCENDANT_CONCEPT_ID
		FROM [dbo].[CONCEPT_ANCESTOR]
		WHERE ANCESTOR_CONCEPT_ID IN
			(SELECT CONCEPT_ID FROM CONCEPT
			WHERE VOCABULARY_ID = 'SNOMED'
			AND (CONCEPT_NAME ='chronic renal impairment' OR CONCEPT_NAME ='CKD - chronic kidney disease')
			AND STANDARD_CONCEPT = 'S') )
			)
			UNION ALL

	(SELECT concept_id, concept_name, class = 'DM'
	FROM CONCEPT
	WHERE CONCEPT_ID IN
		(SELECT DESCENDANT_CONCEPT_ID
		FROM [dbo].[CONCEPT_ANCESTOR]
		WHERE ANCESTOR_CONCEPT_ID IN
			(SELECT CONCEPT_ID FROM CONCEPT
			WHERE VOCABULARY_ID = 'SNOMED'
			AND CONCEPT_NAME ='diabetes mellitus'
			AND STANDARD_CONCEPT = 'S') )
			) 
	UNION ALL		
	(SELECT concept_id, concept_name, class = 'HTN'
	FROM CONCEPT
	WHERE CONCEPT_ID IN
		(SELECT DESCENDANT_CONCEPT_ID
		FROM [dbo].[CONCEPT_ANCESTOR]
		WHERE ANCESTOR_CONCEPT_ID IN
			(SELECT CONCEPT_ID FROM CONCEPT
			WHERE VOCABULARY_ID = 'SNOMED'
			AND CONCEPT_NAME ='Hypertensive disorder'
			AND STANDARD_CONCEPT = 'S') 	)
			)
	UNION ALL		
	(SELECT concept_id, concept_name, class = 'ischemicCVA'
	FROM CONCEPT
	WHERE CONCEPT_ID IN
		(SELECT DESCENDANT_CONCEPT_ID
		FROM [dbo].[CONCEPT_ANCESTOR]
		WHERE ANCESTOR_CONCEPT_ID IN
			(SELECT CONCEPT_ID FROM CONCEPT
			WHERE VOCABULARY_ID = 'SNOMED'
			AND CONCEPT_NAME ='cerebral infarction'
			AND STANDARD_CONCEPT = 'S') 	)
			)
			
			)X

ALTER TABLE temp_SCApt_2 ADD pre_IHD INT
ALTER TABLE temp_SCApt_2 ADD pre_HF INT
ALTER TABLE temp_SCApt_2 ADD pre_arrhythmia INT
ALTER TABLE temp_SCApt_2 ADD pre_VHD INT
ALTER TABLE temp_SCApt_2 ADD pre_CKD INT
ALTER TABLE temp_SCApt_2 ADD pre_DM INT
ALTER TABLE temp_SCApt_2 ADD pre_HTN INT
ALTER TABLE temp_SCApt_2 ADD pre_ischemicCVA INT

--marking IHD patients
UPDATE temp_SCApt_2
	SET pre_IHD = 1
	WHERE PERSON_ID IN 
		(SELECT DISTINCT PERSON_ID 
			FROM temp_SCA_premorb
			WHERE CONDITION_CONCEPT_ID IN
				(SELECT concept_id 
				FROM #comorbidity
				WHERE CLASS = 'IHD'
				)
				)

UPDATE temp_SCApt_2
	SET pre_IHD = 0
	WHERE pre_IHD IS NULL

--marking HF patients
UPDATE temp_SCApt_2
	SET pre_HF = 1
	WHERE PERSON_ID IN 
		(SELECT DISTINCT PERSON_ID 
			FROM temp_SCA_premorb
			WHERE CONDITION_CONCEPT_ID IN
				(SELECT concept_id 
				FROM #comorbidity
				WHERE CLASS = 'HF'
				)
				)

UPDATE temp_SCApt_2
	SET pre_HF = 0
	WHERE pre_HF IS NULL

--marking arrhythmia patients
UPDATE temp_SCApt_2
	SET pre_arrhythmia = 1
	WHERE PERSON_ID IN 
		(SELECT DISTINCT PERSON_ID 
			FROM temp_SCA_premorb
			WHERE CONDITION_CONCEPT_ID IN
				(SELECT concept_id 
				FROM #comorbidity
				WHERE CLASS = 'arrhythmia'
				)
				)
UPDATE temp_SCApt_2
	SET pre_arrhythmia = 0
	WHERE pre_arrhythmia IS NULL


--marking VHD patients
UPDATE temp_SCApt_2
	SET pre_VHD = 1
	WHERE PERSON_ID IN 
		(SELECT DISTINCT PERSON_ID 
			FROM temp_SCA_premorb
			WHERE CONDITION_CONCEPT_ID IN
				(SELECT concept_id 
				FROM #comorbidity
				WHERE CLASS = 'VHD'
				)
				)

UPDATE temp_SCApt_2
	SET pre_VHD = 0
	WHERE pre_VHD IS NULL
--marking CKD patients

UPDATE temp_SCApt_2
	SET pre_CKD = 1
	WHERE PERSON_ID IN 
		(SELECT DISTINCT PERSON_ID 
			FROM temp_SCA_premorb
			WHERE CONDITION_CONCEPT_ID IN
				(SELECT concept_id 
				FROM #comorbidity
				WHERE CLASS = 'CKD'
				)
				)

UPDATE temp_SCApt_2
	SET pre_CKD = 0
	WHERE pre_CKD IS NULL
--marking DM patients
UPDATE temp_SCApt_2
	SET pre_DM = 1
	WHERE PERSON_ID IN 
		(SELECT DISTINCT PERSON_ID 
			FROM temp_SCA_premorb
			WHERE CONDITION_CONCEPT_ID IN
				(SELECT concept_id 
				FROM #comorbidity
				WHERE CLASS = 'DM'
				)
				)

UPDATE temp_SCApt_2
	SET pre_DM = 0
	WHERE pre_DM IS NULL
--marking HTN patients
UPDATE temp_SCApt_2
	SET pre_HTN = 1
	WHERE PERSON_ID IN 
		(SELECT DISTINCT PERSON_ID 
			FROM temp_SCA_premorb
			WHERE CONDITION_CONCEPT_ID IN
				(SELECT concept_id 
				FROM #comorbidity
				WHERE CLASS = 'HTN'
				)
				)

UPDATE temp_SCApt_2
	SET pre_HTN = 0
	WHERE pre_HTN IS NULL


--marking ischemicCVA patients
UPDATE temp_SCApt_2
	SET pre_ischemicCVA = 1
	WHERE PERSON_ID IN 
		(SELECT DISTINCT PERSON_ID 
			FROM temp_SCA_premorb
			WHERE CONDITION_CONCEPT_ID IN
				(SELECT concept_id 
				FROM #comorbidity
				WHERE CLASS = 'ischemicCVA'
				)
				)
UPDATE temp_SCApt_2
	SET pre_ischemicCVA = 0
	WHERE pre_ischemicCVA IS NULL

ALTER TABLE temp_SCApt_2 ADD post_IHD INT
ALTER TABLE temp_SCApt_2 ADD post_HF INT
ALTER TABLE temp_SCApt_2 ADD post_arrhythmia INT
ALTER TABLE temp_SCApt_2 ADD post_VHD INT
ALTER TABLE temp_SCApt_2 ADD post_CKD INT
ALTER TABLE temp_SCApt_2 ADD post_DM INT
ALTER TABLE temp_SCApt_2 ADD post_HTN INT
ALTER TABLE temp_SCApt_2 ADD post_ischemicCVA INT


UPDATE temp_SCApt_2
	SET post_IHD = 1
	WHERE PERSON_ID IN 
		(SELECT DISTINCT PERSON_ID 
			FROM temp_SCA_postmorb
			WHERE CONDITION_CONCEPT_ID IN
				(SELECT concept_id 
				FROM #comorbidity
				WHERE CLASS = 'IHD'
				)
				)

UPDATE temp_SCApt_2
	SET post_IHD = 0
	WHERE pre_IHD = 1

UPDATE temp_SCApt_2
	SET post_IHD = 0
	WHERE post_IHD IS NULL
--marking HF patients
UPDATE temp_SCApt_2
	SET post_HF = 1
	WHERE PERSON_ID IN 
		(SELECT DISTINCT PERSON_ID 
			FROM temp_SCA_postmorb
			WHERE CONDITION_CONCEPT_ID IN
				(SELECT concept_id 
				FROM #comorbidity
				WHERE CLASS = 'HF'
				)
				)

UPDATE temp_SCApt_2
	SET post_HF = 0
	WHERE pre_HF = 1

UPDATE temp_SCApt_2
	SET post_HF = 0
	WHERE post_HF IS NULL
--marking arrhythmia patients
UPDATE temp_SCApt_2
	SET post_arrhythmia = 1
	WHERE PERSON_ID IN 
		(SELECT DISTINCT PERSON_ID 
			FROM temp_SCA_postmorb
			WHERE CONDITION_CONCEPT_ID IN
				(SELECT concept_id 
				FROM #comorbidity
				WHERE CLASS = 'arrhythmia'
				)
				)

UPDATE temp_SCApt_2
	SET post_arrhythmia = 0
	WHERE pre_arrhythmia = 1

UPDATE temp_SCApt_2
	SET post_arrhythmia = 0
	WHERE post_arrhythmia IS NULL
--marking VHD patients
UPDATE temp_SCApt_2
	SET post_VHD = 1
	WHERE PERSON_ID IN 
		(SELECT DISTINCT PERSON_ID 
			FROM temp_SCA_postmorb
			WHERE CONDITION_CONCEPT_ID IN
				(SELECT concept_id 
				FROM #comorbidity
				WHERE CLASS = 'VHD'
				)
				)

UPDATE temp_SCApt_2
	SET post_VHD = 0
	WHERE pre_VHD = 1

UPDATE temp_SCApt_2
	SET post_VHD = 0
	WHERE post_VHD IS NULL
--marking CKD patients

UPDATE temp_SCApt_2
	SET post_CKD = 1
	WHERE PERSON_ID IN 
		(SELECT DISTINCT PERSON_ID 
			FROM temp_SCA_postmorb
			WHERE CONDITION_CONCEPT_ID IN
				(SELECT concept_id 
				FROM #comorbidity
				WHERE CLASS = 'CKD'
				)
				)
UPDATE temp_SCApt_2
	SET post_CKD = 0
	WHERE pre_CKD = 1

UPDATE temp_SCApt_2
	SET post_CKD = 0
	WHERE post_CKD IS NULL
--marking DM patients
UPDATE temp_SCApt_2
	SET post_DM = 1
	WHERE PERSON_ID IN 
		(SELECT DISTINCT PERSON_ID 
			FROM temp_SCA_postmorb
			WHERE CONDITION_CONCEPT_ID IN
				(SELECT concept_id 
				FROM #comorbidity
				WHERE CLASS = 'DM'
				)
				)

UPDATE temp_SCApt_2
	SET post_DM = 0
	WHERE pre_DM = 1
UPDATE temp_SCApt_2
	SET post_DM = 0
	WHERE post_DM IS NULL
--marking HTN patients
UPDATE temp_SCApt_2
	SET post_HTN = 1
	WHERE PERSON_ID IN 
		(SELECT DISTINCT PERSON_ID 
			FROM temp_SCA_postmorb
			WHERE CONDITION_CONCEPT_ID IN
				(SELECT concept_id 
				FROM #comorbidity
				WHERE CLASS = 'HTN'
				)
				)
UPDATE temp_SCApt_2
	SET post_HTN = 0
	WHERE pre_HTN = 1
UPDATE temp_SCApt_2
	SET post_HTN = 0
	WHERE post_HTN IS NULL
--marking ischemicCVA patients
UPDATE temp_SCApt_2
	SET post_ischemicCVA = 1
	WHERE PERSON_ID IN 
		(SELECT DISTINCT PERSON_ID 
			FROM temp_SCA_postmorb
			WHERE CONDITION_CONCEPT_ID IN
				(SELECT concept_id 
				FROM #comorbidity
				WHERE CLASS = 'ischemicCVA'
				)
				)

UPDATE temp_SCApt_2
	SET post_ischemicCVA = 0
	WHERE pre_ischemicCVA = 1
UPDATE temp_SCApt_2
	SET post_ischemicCVA = 0
	WHERE post_ischemicCVA IS NULL

SELECT TOP 100 * FROM temp_SCApt_2

--FIND DEATH information

SELECT person_id, MIN(DEATH_DATE) as death_date
	INTO #SCA_DEATH
	FROM DEATH 
	WHERE PERSON_ID IN 
		(SELECT PERSON_ID FROM temp_SCApt_2)
	GROUP BY PERSON_ID

--MARKING DEATH
ALTER TABLE temp_SCApt_2 ADD DEATH_DATE DATE

UPDATE temp_SCApt_2
	SET DEATH_DATE = B.death_date
	FROM temp_SCApt_2 A
		INNER JOIN #SCA_DEATH B
		ON A.person_id = B.person_id

--procedure & device

SELECT X.*
	INTO #procedure
	FROM
	(
	(SELECT concept_id, concept_name, class = 'PCI'
	FROM CONCEPT
	WHERE CONCEPT_ID IN
	(SELECT DESCENDANT_CONCEPT_ID
			FROM [dbo].[CONCEPT_ANCESTOR]
			WHERE ANCESTOR_CONCEPT_ID IN
				(SELECT CONCEPT_ID FROM CONCEPT
				WHERE CONCEPT_NAME = 'Percutaneous transluminal angioplasty'
				AND STANDARD_CONCEPT = 'S') ) 
				)
	UNION ALL

	(SELECT concept_id, concept_name, class = 'OPCAB'
	FROM CONCEPT
	WHERE CONCEPT_ID IN
	(SELECT DESCENDANT_CONCEPT_ID
			FROM [dbo].[CONCEPT_ANCESTOR]
			WHERE ANCESTOR_CONCEPT_ID IN
				(SELECT CONCEPT_ID FROM CONCEPT
				WHERE CONCEPT_NAME = 'Off-pump coronary artery bypass'
				AND STANDARD_CONCEPT = 'S') )
				)
	UNION ALL

	(SELECT concept_id, concept_name, class = 'TH'
	FROM CONCEPT
	WHERE CONCEPT_ID IN
	(SELECT CONCEPT_ID
		FROM CONCEPT
		WHERE CONCEPT_NAME = 'Hypothermia treatment'
		OR CONCEPT_NAME = 'Hypothermia induction therapy'
		OR CONCEPT_NAME = 'Induction of hypothermia'
		OR CONCEPT_NAME = 'Hypothermia therapy'
		OR CONCEPT_NAME = 'Hypothermia, total body, induction and maintenance'))
	
	UNION ALL

	(SELECT concept_id, concept_name, class = 'ECMO'
	FROM CONCEPT
	WHERE CONCEPT_ID IN
	(SELECT DESCENDANT_CONCEPT_ID
			FROM [dbo].[CONCEPT_ANCESTOR]
			WHERE ANCESTOR_CONCEPT_ID IN
				(SELECT CONCEPT_ID FROM CONCEPT
				WHERE CONCEPT_NAME = 'Extracorporeal membrane oxygenation'
				AND STANDARD_CONCEPT = 'S'))
				)

	UNION ALL 
	(SELECT concept_id, concept_name, class = 'CRRT'
	FROM CONCEPT
	WHERE CONCEPT_ID IN
	(SELECT DESCENDANT_CONCEPT_ID
			FROM [dbo].[CONCEPT_ANCESTOR]
			WHERE ANCESTOR_CONCEPT_ID IN
				(SELECT CONCEPT_ID FROM CONCEPT
				WHERE CONCEPT_NAME = 'Continuous venovenous hemodialysis'
				AND STANDARD_CONCEPT = 'S'))
				)	

	UNION ALL

	(SELECT concept_id, concept_name, class = 'PM'
	FROM CONCEPT
	WHERE CONCEPT_ID IN
	(SELECT DESCENDANT_CONCEPT_ID
			FROM [dbo].[CONCEPT_ANCESTOR]
			WHERE ANCESTOR_CONCEPT_ID IN
				(SELECT CONCEPT_ID FROM CONCEPT
				WHERE CONCEPT_NAME = 'Insertion of pacemaker pulse generator'
				AND STANDARD_CONCEPT = 'S'))
				)

	UNION ALL

	(SELECT concept_id, concept_name, class = 'IABP'
	FROM CONCEPT
	WHERE CONCEPT_ID IN
	(SELECT DESCENDANT_CONCEPT_ID
			FROM [dbo].[CONCEPT_ANCESTOR]
			WHERE ANCESTOR_CONCEPT_ID IN
				(SELECT CONCEPT_ID FROM CONCEPT
				WHERE CONCEPT_NAME = 'Intraaortic balloon pump maintenance'
				AND STANDARD_CONCEPT = 'S'))
				)

	UNION ALL 

	(SELECT concept_id, concept_name, class = 'ICD'
	FROM CONCEPT
	WHERE CONCEPT_ID IN
	(SELECT DESCENDANT_CONCEPT_ID
			FROM [dbo].[CONCEPT_ANCESTOR]
			WHERE ANCESTOR_CONCEPT_ID IN
				(SELECT CONCEPT_ID FROM CONCEPT
				WHERE CONCEPT_NAME = 'Defibrillator electrode'
				AND STANDARD_CONCEPT = 'S'))
			)
		) X
		
--find procedures of patients
IF OBJECT_ID('temp_SCA_procedure', 'U') IS NOT NULL
	DROP TABLE temp_SCA_procedure;

SELECT DISTINCT A.person_id, A.procedure_concept_id, A.procedure_date, A.visit_occurrence_id, B.hospital_start, B.hospital_end, B.sca_date
	INTO  temp_SCA_procedure
	FROM PROCEDURE_OCCURRENCE A
	JOIN temp_SCApt_2 B
	ON A.PERSON_ID = B.PERSON_ID
	WHERE A.procedure_date >= b.hospital_start


--find devices of patients
IF OBJECT_ID('temp_SCA_device', 'U') IS NOT NULL
	DROP TABLE temp_SCA_device;

SELECT DISTINCT A.person_id, A.device_concept_id, A.device_exposure_start_date, A.visit_occurrence_id, B.hospital_start, B.hospital_end, B.sca_date
	INTO  temp_SCA_device
	FROM DEVICE_EXPOSURE A
	JOIN temp_SCApt_2 B
	ON A.PERSON_ID = B.PERSON_ID
	WHERE A.device_exposure_start_date >= b.hospital_start


ALTER TABLE temp_SCApt_2 ADD PCI INT
ALTER TABLE temp_SCApt_2 ADD OPCAB INT
ALTER TABLE temp_SCApt_2 ADD TH INT
ALTER TABLE temp_SCApt_2 ADD ECMO INT
ALTER TABLE temp_SCApt_2 ADD CRRT INT
ALTER TABLE temp_SCApt_2 ADD PM INT
ALTER TABLE temp_SCApt_2 ADD IABP INT
ALTER TABLE temp_SCApt_2 ADD ICD INT

UPDATE temp_SCApt_2
	SET PCI = 1
	WHERE PERSON_ID IN 
		(SELECT DISTINCT PERSON_ID 
			FROM temp_SCA_procedure
			WHERE procedure_CONCEPT_ID IN
				(SELECT concept_id 
				FROM #procedure
				WHERE CLASS = 'PCI'
				)
				)
UPDATE temp_SCApt_2
	SET PCI = 0
	WHERE PCI IS NULL

UPDATE temp_SCApt_2
	SET OPCAB = 1
	WHERE PERSON_ID IN 
		(SELECT DISTINCT PERSON_ID 
			FROM temp_SCA_procedure
			WHERE procedure_CONCEPT_ID IN
				(SELECT concept_id 
				FROM #procedure
				WHERE CLASS = 'OPCAB'
				)
				)
UPDATE temp_SCApt_2
	SET OPCAB = 0
	WHERE OPCAB IS NULL
UPDATE temp_SCApt_2
	SET TH = 1
	WHERE PERSON_ID IN 
		(SELECT DISTINCT PERSON_ID 
			FROM temp_SCA_procedure
			WHERE procedure_CONCEPT_ID IN
				(SELECT concept_id 
				FROM #procedure
				WHERE CLASS = 'TH'
				)
				)
UPDATE temp_SCApt_2
	SET TH = 0
	WHERE TH IS NULL
UPDATE temp_SCApt_2
	SET ECMO = 1
	WHERE PERSON_ID IN 
		(SELECT DISTINCT PERSON_ID 
			FROM temp_SCA_procedure
			WHERE procedure_CONCEPT_ID IN
				(SELECT concept_id 
				FROM #procedure
				WHERE CLASS = 'ECMO'
				) )
UPDATE temp_SCApt_2
	SET ECMO = 0
	WHERE ECMO IS NULL		

UPDATE temp_SCApt_2
	SET CRRT = 1
	WHERE PERSON_ID IN 
		(SELECT DISTINCT PERSON_ID 
			FROM temp_SCA_procedure
			WHERE procedure_CONCEPT_ID IN
				(SELECT concept_id 
				FROM #procedure
				WHERE CLASS = 'CRRT'
				)
				)
UPDATE temp_SCApt_2
	SET CRRT = 0
	WHERE CRRT IS NULL		



UPDATE temp_SCApt_2
	SET PM = 1
	WHERE PERSON_ID IN 
		(SELECT DISTINCT PERSON_ID 
			FROM temp_SCA_procedure
			WHERE procedure_CONCEPT_ID IN
				(SELECT concept_id 
				FROM #procedure
				WHERE CLASS = 'PM'
				)
				)
UPDATE temp_SCApt_2
	SET PM = 0
	WHERE PM IS NULL		

UPDATE temp_SCApt_2
	SET IABP = 1
	WHERE PERSON_ID IN 
		(SELECT DISTINCT PERSON_ID 
			FROM temp_SCA_procedure
			WHERE procedure_CONCEPT_ID IN
				(SELECT concept_id 
				FROM #procedure
				WHERE CLASS = 'IABP'
				)
				)
UPDATE temp_SCApt_2
	SET IABP = 0
	WHERE IABP IS NULL

UPDATE temp_SCApt_2
	SET ICD = 1
	WHERE PERSON_ID IN 
		(SELECT DISTINCT PERSON_ID 
			FROM temp_SCA_device
			WHERE device_CONCEPT_ID IN
				(SELECT concept_id 
				FROM #procedure
				WHERE CLASS = 'ICD'
				)
				)
UPDATE temp_SCApt_2
	SET ICD = 0
	WHERE ICD IS NULL

--marking gender of patients

ALTER TABLE temp_SCApt_2 ADD gender_concept_id INT

UPDATE temp_SCApt_2
	SET gender_concept_id = B.gender_concept_id
	FROM temp_SCApt_2 A
		INNER JOIN person B
		ON A.person_id = B.person_id

--Male = 8507
--Female = 8532

