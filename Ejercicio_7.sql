-- 7. Generar el campo billing_account_id

SELECT   calls.ivr_id                             AS calls_ivr_id
       , steps.billing_account_id                 AS step_billing_account_id

  FROM `keepcoding.ivr_calls` calls
  LEFT 
  JOIN `keepcoding.ivr_steps` steps
    ON calls.ivr_id = steps.ivr_id
QUALIFY ROW_NUMBER() OVER(PARTITION BY CAST(calls.ivr_id AS STRING) ORDER BY IF(steps.billing_account_id  <> 'UNKNOWN' OR steps.billing_account_id  <> 'DESCONOCIDO', 1, 0) DESC) = 1
