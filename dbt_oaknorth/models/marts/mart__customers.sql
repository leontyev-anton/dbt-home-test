/*
Model that consolidates relevant customer information with their transactions:
- amount_total: total transactions made by each customer
- amount_average_month: their average monthly spending (number of months between first and last transaction)
- spending_interval_avg: the average customer spending interval, representing the average number of days it takes for the customer to perform a transaction


*/



-- This code block return 'int__transactions' with adding column
-- 'spending_interval' (amount of days between current and previous transaction)
WITH transactions_add_spending_interval AS
(
   SELECT
      *,
      DATE_DIFF(transaction_date, transaction_date_previous, DAY) AS spending_interval,

   FROM
   (
      SELECT
         customer_id, transaction_month, transaction_date, amount, name AS customer_name, joined_date AS customer_joined_date, 
         LAG(transaction_date) OVER (PARTITION BY customer_id ORDER BY transaction_date, transaction_id DESC) AS transaction_date_previous,

      FROM {{ ref('int__transactions')  
      WHERE error_text IS NULL
   )
)





SELECT
   customer_id, customer_name, customer_joined_date, amount_total,
   ROUND(amount_total / months_between_first_last_transaction,2) AS amount_average_month,
   months_payed,
   months_between_first_last_transaction,
   spending_interval_avg,

FROM
(
   SELECT
      customer_id, customer_name, customer_joined_date,
      SUM(amount) AS amount_total,
      COUNT(DISTINCT transaction_month) AS months_payed,
      DATE_DIFF( 
         DATE_TRUNC(MAX(transaction_date), MONTH),
         DATE_TRUNC(MIN(transaction_date), MONTH),
         MONTH
      ) +1 AS months_between_first_last_transaction,
      ROUND(AVG(spending_interval),2) AS spending_interval_avg,

   FROM transactions_add_spending_interval
   GROUP BY customer_id, customer_name, customer_joined_date
)
ORDER BY customer_id