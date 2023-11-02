/*
Staging layer - Checking the source table 'transactions'.
Output row 'error_text' should be NULL for using on next(Intermediate) layer.
Adding columns from table 'stg__customers'.

*/




SELECT 
   t.transaction_id,
   t.customer_id,
   t.transaction_date_source,
   t.transaction_date_cast,
   t.amount,
   c.name,
   c.date_of_birth,
   c.joined_date,
   CASE 
      WHEN t.row_num!=1 THEN 'dublicate transaction_id'
      WHEN c.customer_id IS NULL THEN 'wrong customer_id'
      WHEN t.transaction_date_cast IS NULL THEN 'transaction_date IS NULL'
      --WHEN t.transaction_date_cast>CURRENT_DATE() THEN 'transaction_date from future'
      WHEN t.transaction_date_cast>'2024-01-01' THEN 'transaction_date from future'
      WHEN t.transaction_date_cast<c.joined_date THEN 'transaction before joining'
      WHEN t.amount<=0 OR t.amount IS NULL THEN 'wrong amount'
      ELSE NULL
   END AS error_text,

FROM
(
   SELECT 
      *, 
      -- looking for doubles in transaction_id (in case the double 'row_num' is > 1)
      ROW_NUMBER() OVER (PARTITION BY transaction_id ORDER BY transaction_date_cast, customer_id, amount DESC) AS row_num

   FROM
   (
      SELECT  
         transaction_id, 
         customer_id, 
         transaction_date AS transaction_date_source, 
         SAFE_CAST(transaction_date AS DATE) AS transaction_date_cast,
         amount

      FROM {{ ref('transactions') }} 
   )
) AS t

LEFT JOIN 
(
   SELECT customer_id, name, date_of_birth, joined_date,
   FROM {{ ref('stg__customers') }}
   WHERE error_text IS NULL
) AS c ON c.customer_id=t.customer_id

ORDER BY t.transaction_id