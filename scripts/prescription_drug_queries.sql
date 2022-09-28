--Q1a

SELECT npi,SUM(total_claim_count) AS total_claims
FROM prescriber
FULL JOIN prescription USING(npi)
WHERE total_claim_count IS NOT NULL
GROUP BY npi
ORDER BY total_claims DESC;
--ANSWER: NPI:1881634483 WITH 99707 TOTAL CLAIMS

--Q1b

SELECT npi,nppes_provider_first_name,nppes_provider_last_org_name,
		specialty_description,SUM(total_claim_count) AS total_claims
FROM prescriber
FULL JOIN prescription USING(npi)
WHERE total_claim_count IS NOT NULL
GROUP BY npi,nppes_provider_first_name,nppes_provider_last_org_name,
		specialty_description
ORDER BY total_claims DESC;
--Answer: Bruce Pendley,Family Practice with 99707 total claims


--Q2a

SELECT specialty_description, SUM(total_claim_count) AS total_claims
FROM prescription
FULL JOIN prescriber USING(npi)
WHERE total_claim_count IS NOT NULL
GROUP BY specialty_description
ORDER BY total_claims DESC;
--Answer: Family Practice with 9752347 total claims


--Q2b

SELECT specialty_description, COUNT(opioid_drug_flag='Y') as opioid_claims
FROM prescriber
INNER JOIN prescription USING (npi)
INNER JOIN drug USING(drug_name)
WHERE total_claim_count IS NOT NULL
GROUP BY specialty_description
ORDER BY opioid_claims DESC;
--Answer: Nurse Practitioner with 175734 opioid claims


--Q2c (Challenge Question)

SELECT specialty_description,COUNT(total_claim_count IS NULL) AS no_claims
FROM prescriber
FULL JOIN prescription USING(npi)
WHERE drug_name IS NULL
GROUP BY specialty_description
ORDER BY no_claims DESC;
--Answer: Nurse Practitioner with 1048 no claims for prescriptions

--Q2d (Difficult Bonus)


--Q3a

SELECT generic_name,SUM(total_drug_cost) AS total_cost
FROM drug
FULL JOIN prescription USING(drug_name)
WHERE total_drug_cost IS NOT NULL
GROUP BY generic_name
ORDER BY total_cost DESC;
--Answer: "INSULIN GLARGINE,HUM.REC.ANLOG" highest with 104264066.35


--Q3b

SELECT generic_name, ROUND(SUM(total_drug_cost)/365,2) AS cost_per_day
FROM drug
FULL JOIN prescription USING(drug_name)
WHERE total_drug_cost IS NOT NULL
GROUP BY generic_name
ORDER BY cost_per_day DESC;
--Answer: "INSULIN GLARGINE,HUM.REC.ANLOG" highest with 285654.98 cost per day


--Q4a

SELECT drug_name,
	CASE WHEN opioid_drug_flag='Y' THEN 'opioid'
		 WHEN antibiotic_drug_flag='Y' THEN 'antibiotic'
	ELSE 'neither' END AS drug_type
FROM drug;


--Q4b TRY SUBQUERY

SELECT SUM(total_drug_cost)::money AS total_cost,
	CASE WHEN opioid_drug_flag='Y' THEN 'opioid'
		 WHEN antibiotic_drug_flag='Y' THEN 'antibiotic'
	ELSE 'neither' END AS drug_type
FROM drug
INNER JOIN prescription USING(drug_name)
GROUP BY drug_type
ORDER BY total_cost DESC;
--Answer: More was spent on OPIOIDS - $105,080,626.37


--Q5a

SELECT *
FROM cbsa
LEFT JOIN fips_county USING (fipscounty)
WHERE state='TN';
--Answer: 42 cbsa's in TN


--Q5b

SELECT cbsaname,SUM(population) AS total_pop
FROM population
INNER JOIN cbsa USING(fipscounty)
GROUP BY cbsaname
ORDER BY total_pop;
--Answer: highest population:
--Nashville-Davidson--Murfreesboro--Franklin, TN with 1830410
--Lowest population:
--Morristown, TN with 116352


--Q5c

SELECT county,SUM(population) as total_pop
FROM cbsa
FULL JOIN fips_county USING(fipscounty)
FULL JOIN population USING(fipscounty)
WHERE cbsaname IS NULL
AND population IS NOT NULL
GROUP BY county
ORDER BY total_pop DESC;
--Answer: Sevier with 95523


--Q6a

SELECT drug_name,SUM(total_claim_count) AS total_claims
FROM prescription
WHERE total_claim_count>=3000
GROUP BY drug_name
ORDER BY total_claims DESC;


--Q6b

SELECT drug_name,SUM(total_claim_count) AS total_claims,
	CASE WHEN opioid_drug_flag='Y' THEN 'opioid'
		ELSE 'NA' END AS opioid
FROM prescription
INNER JOIN drug USING (drug_name)
WHERE total_claim_count>=3000
GROUP BY drug_name, opioid
ORDER BY total_claims DESC;


--Q6c

SELECT drug_name,
	nppes_provider_first_name,
	nppes_provider_last_org_name,
	total_claim_count,
	CASE WHEN opioid_drug_flag='Y' THEN 'opioid'
		ELSE '' END AS opioid
FROM prescription
INNER JOIN drug USING (drug_name)
INNER JOIN prescriber USING (npi)
WHERE total_claim_count>=3000
ORDER BY total_claim_count DESC;


--Q7a CROSS JOIN, REDO IT

WITH drugs AS (SELECT npi,drug_name,opioid_drug_flag
		   FROM drug
		   INNER JOIN prescription USING(drug_name))

SELECT *
FROM prescriber
INNER JOIN drugs USING (npi)
WHERE specialty_description='Pain Management'
AND nppes_provider_city='NASHVILLE'
AND opioid_drug_flag='Y';


--Q7b

SELECT npi,drug_name,total_claim_count
FROM prescriber
FULL JOIN prescription USING(npi)
FULL JOIN drug USING(drug_name)
WHERE specialty_description='Pain Management'
AND nppes_provider_city='NASHVILLE'
AND opioid_drug_flag='Y'
ORDER BY total_claim_count DESC;


--Q7a

WITH opioids AS (SELECT*
	FROM drug
	WHERE opioid_drug_flag='Y')

SELECT p1.npi,p1.specialty_description,
FROM prescriber as p1
INNER JOIN prescriber as p2 USING(npi)
WHERE p1.specialty_description='Pain Management'
AND p1.nppes_provider_city='NASHVILLE'