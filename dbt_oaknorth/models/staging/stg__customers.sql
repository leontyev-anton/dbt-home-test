/*
Staging layer - Checking the source table 'customers'.


*/





SELECT
   *,
   IF (row_num!=1, 'dublicate customer_id', NULL) AS error_text,


FROM
(
   SELECT  
      customer_id,
      name,
      date_of_birth,
      SAFE_CAST(joined_date AS DATE) AS joined_date,
      -- looking for doubles in customer_id (in case the double 'row_num' is > 1)
      ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY joined_date, date_of_birth ) AS row_num

   FROM {{ ref('customers') }} 
)
ORDER BY customer_id