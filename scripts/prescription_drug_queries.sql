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
FULL JOIN prescription USING (npi)
FULL JOIN drug USING(drug_name)
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


--Q4b

SELECT SUM(total_drug_cost)::money AS total_cost,
	CASE WHEN opioid_drug_flag='Y' THEN 'opioid'
		 WHEN antibiotic_drug_flag='Y' THEN 'antibiotic'
	ELSE 'neither' END AS drug_type
FROM drug
FULL JOIN prescription USING(drug_name)
WHERE total_drug_cost IS NOT NULL
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
ORDER BY total_pop DESC;
