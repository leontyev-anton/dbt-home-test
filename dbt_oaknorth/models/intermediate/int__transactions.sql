/*
Intermediate layer - preparing the source table 'transactions' for further usage in marts.
We take all error-free rows from 'stg__transactions'.

*/




SELECT 
   transaction_id,
   customer_id,
   transaction_date_cast AS transaction_date,
   FORMAT_DATE('%Y-%m', transaction_date_cast) AS transaction_month,
   amount,
   name,
   date_of_birth,
   joined_date,
   LAG(transaction_date_cast) OVER (PARTITION BY customer_id ORDER BY transaction_date_cast, transaction_id DESC) AS transaction_previous_date,

FROM {{ ref('stg__transactions') }}
WHERE error_text IS NULL
ORDER BY customer_id, transaction_date