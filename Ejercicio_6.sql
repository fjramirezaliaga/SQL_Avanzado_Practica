--6. Generar el campo customer_phone

SELECT   calls.ivr_id                             AS calls_ivr_id
       , steps.customer_phone                     AS step_customer_phone

FROM `keepcoding.ivr_calls` calls
LEFT 
JOIN `keepcoding.ivr_steps` steps
  ON calls.ivr_id = steps.ivr_id
QUALIFY ROW_NUMBER() OVER(PARTITION BY CAST(calls.ivr_id AS STRING) ORDER BY IF(steps.customer_phone  <> 'UNKNOWN', 1, 0) DESC) = 1
