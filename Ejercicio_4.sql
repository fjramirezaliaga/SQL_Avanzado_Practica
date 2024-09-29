--  4. Generar el campo vdn_aggregation

SELECT calls.ivr_id                AS calls_ivr_id
     , CASE WHEN LEFT(calls.vdn_label,3) = 'ATC'          THEN 'FRONT'
            WHEN LEFT(calls.vdn_label,4) = 'TECH'         THEN 'TECH'
            WHEN calls.vdn_label         = 'ABSORPTION'   THEN 'ABSORPTION'
            ELSE 'RESTO'     
       END                         AS calls_vdn_aggregation
FROM `keepcoding.ivr_calls` calls