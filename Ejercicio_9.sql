--9. Generar el campo info_by_phone_lg

SELECT    calls.ivr_id                                      AS calls_ivr_id
        , IF(steps.step_name = 'CUSTOMERINFOBYPHONE.TX' 
             AND steps.step_result = 'OK', 1, 0)            AS info_by_phone_lg
FROM `keepcoding.ivr_calls` calls
LEFT 
JOIN `keepcoding.ivr_steps` steps
  ON calls.ivr_id = steps.ivr_id
QUALIFY ROW_NUMBER() OVER (PARTITION BY CAST(calls.ivr_id AS STRING) ORDER BY info_by_phone_lg DESC) = 1