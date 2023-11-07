


SELECT *
FROM {{ ref('int__transactions') }}
WHERE error_text IS NOT NULL