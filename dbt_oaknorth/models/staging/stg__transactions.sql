/*
Staging layer - Checking the source table 'transactions'.


*/




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