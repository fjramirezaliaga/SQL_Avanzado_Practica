--5. Generar los campos document_type y document_identification

SELECT  calls.ivr_id                             AS calls_ivr_id
      , steps.document_type                      AS step_document_type
      , steps.document_identification            AS step_document_identification 

FROM `keepcoding.ivr_calls` calls
LEFT 
JOIN  `keepcoding.ivr_steps` steps
  ON calls.ivr_id = steps.ivr_id
QUALIFY ROW_NUMBER() OVER(PARTITION BY CAST(calls.ivr_id AS STRING) ORDER BY IF(steps.document_type  <> 'UNKNOWN' OR steps.document_type  <> 'DESCONOCIDO', 1, 0) DESC) = 1


