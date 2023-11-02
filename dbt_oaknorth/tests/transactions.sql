


SELECT *
FROM {{ ref('stg__transactions') }}
WHERE error_text IS NOT NULL