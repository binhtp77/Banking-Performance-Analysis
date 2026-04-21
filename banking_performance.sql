USE dataset_project_banking;

-- 1. Total Amount over years
SELECT YEAR(date) AS "date",
	SUM(amount) AS total_amount
FROM fact_transactions
WHERE errors = "Successful transaction"
GROUP BY 1
ORDER BY 1 ASC;

-- 2. Percentage of successful transactions made by use_ship
SELECT use_chip,
	COUNT(id) AS total_transactions
FROM fact_transactions
WHERE errors = "Successful transaction"
GROUP BY 1
ORDER BY 1 ASC;

-- 3. Active users by year
SELECT YEAR(date) AS "year",
	COUNT(DISTINCT client_id) AS total_users
FROM fact_transactions
GROUP BY 1
ORDER BY 1 ASC;

-- 4. Errors breakdown
SELECT errors,
	COUNT(id) AS number_of_errors
FROM fact_transactions
WHERE errors != "Successful transaction"
GROUP BY 1
ORDER BY 2 DESC;

-- 5. Top mcc category with total transaction amount greater than average amount
SELECT m.category,
	SUM(t.amount) AS total_amount
FROM fact_transactions t
LEFT JOIN dim_mcc m
ON t.mcc = m.mcc
WHERE errors = "Successful transaction"
GROUP BY 1
HAVING SUM(t.amount) > (
	SELECT AVG(amount) 
    FROM fact_transactions 
    WHERE errors = "Successful transaction"
)
ORDER BY 2 DESC;


-- 5. Total cards breakdown by brand and type issued by year
SELECT 
    YEAR(acct_open_date	) AS "year",
    card_brand,
    COUNT(id) AS total_cards
FROM dim_cards
GROUP BY 1,2
ORDER BY 1 ASC, 3 DESC;

-- 6. Total cards issued breakdown by card type and percentage over years
WITH card_quantity AS(
	SELECT
		YEAR(acct_open_date) AS "year",
		card_type,
		COUNT(id) AS total_cards_issued
	FROM dim_cards
	GROUP BY 1,2
)
SELECT *,
    CONCAT(
		ROUND(
			(total_cards_issued*100)/(SUM(total_cards_issued) OVER(PARTITION BY year))
            ,2
		),'%') AS pct
FROM card_quantity
ORDER BY 1 ASC, 3 DESC;

-- 7. Thẻ có chip hay ko có chip hay gặp lỗi?
SELECT 
	c.has_chip,
    COUNT(t.errors) AS nn
FROM fact_transactions t
LEFT JOIN dim_cards c
ON t.card_id = c.id
WHERE t.errors != "Successful transaction"
GROUP BY 1;

-- 8. User segment
WITH user_group AS (
SELECT *,
	CASE
		WHEN current_age BETWEEN 18 AND 25 THEN "Young Adults"
        WHEN current_age BETWEEN 26 AND 45 THEN "Adults"
        WHEN current_age BETWEEN 46 AND 60 THEN "Middle-Aged Adult"
        ELSE "Elderly"
	END AS age_group
FROM dim_users
)
SELECT
	age_group,
    AVG(per_capita_income) AS avg_per_capita_income,
    AVG(yearly_income) AS avg_yearly_income,
    AVG(total_debt) AS avg_total_debt,
    AVG(credit_score) AS avg_credit_score,
    AVG(num_credit_cards) AS AVG_num_credit_cards
FROM user_group
GROUP BY 1;
