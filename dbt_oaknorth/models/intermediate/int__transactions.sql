/*
Intermediate layer - preparing the source table 'transactions' for further usage in marts.
Fullfill column 'error_text' - should be NULL for using on next (marts) layer.
Adding columns from table 'stg__customers'.

*/


SELECT
   t.transaction_id,
   t.customer_id,
   t.transaction_date,
   t.transaction_month,
   t.amount,   
   t.transaction_previous_date,
   c.name,
   c.date_of_birth,
   c.joined_date,
   CASE 
      WHEN t.row_num!=1 THEN 'dublicate transaction_id'
      WHEN c.customer_id IS NULL THEN 'wrong customer_id'
      WHEN t.transaction_date IS NULL THEN 'transaction_date IS NULL'
      --WHEN t.transaction_date_cast>CURRENT_DATE() THEN 'transaction_date from future'
      WHEN t.transaction_date>'2024-01-01' THEN 'transaction_date from future'
      WHEN t.transaction_date<c.joined_date THEN 'transaction before joining'
      WHEN t.amount<=0 OR t.amount IS NULL THEN 'wrong amount'
      ELSE NULL
   END AS error_text,   
   
FROM
(
   SELECT 
      transaction_id,
      row_num, -- looking for doubles in transaction_id (in case the double 'row_num' is > 1)
      customer_id,
      transaction_date_cast AS transaction_date,
      FORMAT_DATE('%Y-%m', transaction_date_cast) AS transaction_month,
      amount,
      LAG(transaction_date_cast) OVER (PARTITION BY customer_id ORDER BY transaction_date_cast, transaction_id DESC) AS transaction_previous_date,

   FROM {{ ref('stg__transactions') }}
) AS t

LEFT JOIN 
(
   SELECT customer_id, name, date_of_birth, joined_date,
   FROM {{ ref('stg__customers') }}
   WHERE error_text IS NULL
) AS c ON c.customer_id=t.customer_id

ORDER BY customer_id, transaction_date