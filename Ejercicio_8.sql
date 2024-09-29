--8. Generar el campo masiva_lg

SELECT  calls.ivr_id                                          AS calls_ivr_id
      , IF(modules.module_name = 'AVERIA_MASIVA', 1, 0)       AS averia_masiva_flag

FROM `keepcoding.ivr_calls` calls
LEFT 
JOIN `keepcoding.ivr_modules` modules
  ON calls.ivr_id = modules.ivr_id
QUALIFY ROW_NUMBER() OVER (PARTITION BY CAST(calls.ivr_id AS STRING) ORDER BY averia_masiva_flag DESC ) = 1
