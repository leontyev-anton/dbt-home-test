/*
Model that calculates the total transaction amount for each month over the last 12 months
- percent_change_amount: the percentage change in transaction totals from one month to the next
- top_customer_id: calculate the top customer for each month by selecting the customer with the highest spending


*/



WITH generate_last_12_months AS
(
   SELECT FORMAT_DATE('%Y-%m', first_date_month) AS month,
   FROM UNNEST(
      GENERATE_DATE_ARRAY(
         DATE_ADD(
            DATE(EXTRACT(YEAR FROM CURRENT_DATE()), EXTRACT(MONTH FROM CURRENT_DATE()), 1), 
            INTERVAL -11 MONTH
         ), 
         DATE(EXTRACT(YEAR FROM CURRENT_DATE()), EXTRACT(MONTH FROM CURRENT_DATE()), 1), 
         INTERVAL 1 MONTH
      )
   ) AS first_date_month 
)




SELECT
   month, amount, amount_previous_month,
   IF (amount_previous_month = 0, NULL, ROUND(100*(amount - amount_previous_month)/amount,2)) AS percent_change_amount,
   top_customer_id, top_customer_name, top_customer_joined_date, top_customer_amount,

FROM
(
   SELECT
      m.month,
      IFNULL(t.amount,0) AS amount,
      LAG(t.amount) OVER (ORDER BY m.month) AS amount_previous_month,
      c.customer_id AS top_customer_id,
      c.name AS top_customer_name,
      c.joined_date AS top_customer_joined_date,
      c.amount AS top_customer_amount,

   FROM generate_last_12_months AS m

   -- total amount for every month
   LEFT JOIN
   (
      SELECT transaction_month, SUM(amount) AS amount
      FROM {{ ref('int__transactions') }}
      GROUP BY transaction_month
   ) AS t ON t.transaction_month=m.month

   -- looking for top customer in every month
   LEFT JOIN
   (
      SELECT customer_id, name, joined_date, transaction_month, amount
      FROM
      (
         SELECT
            customer_id, name, joined_date, transaction_month, amount,
            ROW_NUMBER() OVER (PARTITION BY transaction_month ORDER BY amount DESC, customer_id) AS row_num

         FROM
         (
            SELECT customer_id, name, joined_date, transaction_month, SUM(amount) AS amount
            FROM {{ ref('int__transactions')  }}
            GROUP BY customer_id, transaction_month, name, joined_date
         )
         ORDER BY transaction_month, amount DESC
      )
      WHERE row_num=1
   ) AS c ON c.transaction_month=m.month
)
ORDER BY month