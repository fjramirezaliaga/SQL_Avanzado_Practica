--12. CREAR TABLA DE ivr_summary (Para nota)

CREATE OR REPLACE TABLE keepcoding.ivr_summary AS
WITH aggregation 
  AS (SELECT calls.ivr_id            AS ivr_id
       , CASE WHEN LEFT(calls.vdn_label,3) = 'ATC'          THEN 'FRONT'
              WHEN LEFT(calls.vdn_label,4) = 'TECH'         THEN 'TECH'
              WHEN calls.vdn_label         = 'ABSORPTION'   THEN 'ABSORPTION'
         ELSE 'RESTO'     
         END                         AS vdn_aggregation
       FROM `keepcoding.ivr_calls` calls)
   , document
   AS (SELECT  calls.ivr_id                             AS calls_ivr_id
             , steps.document_type                      AS step_document_type
             , steps.document_identification            AS step_document_identification 
       FROM `keepcoding.ivr_calls` calls
       LEFT 
       JOIN  `keepcoding.ivr_steps` steps
          ON calls.ivr_id = steps.ivr_id
       QUALIFY ROW_NUMBER() OVER(PARTITION BY CAST(calls.ivr_id AS STRING) ORDER BY IF(steps.document_type  <> 'UNKNOWN' OR steps.document_type  <> 'DESCONOCIDO', 1, 0) DESC) = 1)    
   , cust_phone
   AS (SELECT   calls.ivr_id                             AS calls_ivr_id
              , steps.customer_phone                     AS step_customer_phone
       FROM `keepcoding.ivr_calls` calls
       LEFT 
       JOIN `keepcoding.ivr_steps` steps
          ON calls.ivr_id = steps.ivr_id
       QUALIFY ROW_NUMBER() OVER(PARTITION BY CAST(calls.ivr_id AS STRING) ORDER BY IF(steps.customer_phone  <> 'UNKNOWN', 1, 0) DESC) = 1)
   , billing
   AS (SELECT   calls.ivr_id                             AS calls_ivr_id
              , steps.billing_account_id                 AS step_billing_account_id
       FROM `keepcoding.ivr_calls` calls
       LEFT 
       JOIN `keepcoding.ivr_steps` steps
          ON calls.ivr_id = steps.ivr_id
       QUALIFY ROW_NUMBER() OVER(PARTITION BY CAST(calls.ivr_id AS STRING) ORDER BY IF(steps.billing_account_id  <> 'UNKNOWN' OR steps.billing_account_id  <> 'DESCONOCIDO', 1, 0) DESC) = 1)
   , masiva
   AS (SELECT  calls.ivr_id                                           AS calls_ivr_id
             , IF(modules.module_name = 'AVERIA_MASIVA', 1, 0)        AS averia_masiva_flag
       FROM `keepcoding.ivr_calls` calls
       LEFT 
       JOIN `keepcoding.ivr_modules` modules
          ON calls.ivr_id = modules.ivr_id
       QUALIFY ROW_NUMBER() OVER (PARTITION BY CAST(calls.ivr_id AS STRING) ORDER BY averia_masiva_flag DESC ) = 1)
   , info_by_phone
   AS (SELECT    calls.ivr_id                                         AS calls_ivr_id
               , IF(steps.step_name = 'CUSTOMERINFOBYPHONE.TX' 
                   AND steps.step_result = 'OK', 1, 0)                AS info_by_phone_lg
       FROM `keepcoding.ivr_calls` calls
       LEFT 
       JOIN `keepcoding.ivr_steps` steps
          ON calls.ivr_id = steps.ivr_id
       QUALIFY ROW_NUMBER() OVER (PARTITION BY CAST(calls.ivr_id AS STRING) ORDER BY info_by_phone_lg DESC) = 1) 
   , info_by_id
   AS (SELECT    calls.ivr_id                                         AS calls_ivr_id
               , IF(steps.step_name = 'CUSTOMERINFOBYDNI.TX' 
                   AND steps.step_result = 'OK', 1, 0)                AS info_by_dni_lg      
       FROM `keepcoding.ivr_calls` calls
       LEFT 
       JOIN `keepcoding.ivr_steps` steps
          ON calls.ivr_id = steps.ivr_id
       QUALIFY ROW_NUMBER() OVER (PARTITION BY CAST(calls.ivr_id AS STRING) ORDER BY info_by_dni_lg DESC ) = 1)
   , twenty_four_h
   AS (SELECT ivr_id
            , phone_number
            , IF(DATE_DIFF(start_date, LAG(start_date) OVER (PARTITION BY phone_number ORDER BY start_date), DAY) <= 1, 1, 0)  AS repeated_phone_24H
            , IF(DATE_DIFF(LEAD(start_date) OVER (PARTITION BY phone_number ORDER BY start_date), start_date, DAY) <= 1, 1, 0) AS cause_recall_phone_24H
       FROM `keepcoding.ivr_calls`
       ORDER BY phone_number, start_date)

SELECT   ivr_detail.calls_ivr_id                        AS ivr_id
       , ivr_detail.calls_ivr_phone_number              AS phone_number
       , ivr_detail.calls_ivr_result                    AS ivr_result
       , aggregation.vdn_aggregation                    AS vdn_aggregation
       , ivr_detail.calls_start_date                    AS start_date
       , ivr_detail.calls_end_date                      AS end_date
       , ivr_detail.calls_total_duration                AS total_duration
       , ivr_detail.calls_customer_segment              AS customer_segment
       , ivr_detail.calls_ivr_language                  AS ivr_language
       , ivr_detail.calls_steps_module                  AS steps_module
       , ivr_detail.calls_module_aggregation            AS module_aggregation
       , document.step_document_type                    AS document_type
       , document.step_document_identification          AS document_identification
       , cust_phone.step_customer_phone                 AS customer_phone
       , billing.step_billing_account_id                AS billing_account_id
       , masiva.averia_masiva_flag                      AS masiva_lg
       , info_by_phone.info_by_phone_lg                 AS info_by_phone_lg
       , info_by_id.info_by_dni_lg                      AS info_by_dni_lg
       , twenty_four_h.repeated_phone_24H               AS repeated_phone_24H
       , twenty_four_h.cause_recall_phone_24H           AS cause_recall_phone_24H

FROM `keepcoding.ivr_detail` ivr_detail
LEFT
JOIN aggregation
    ON ivr_detail.calls_ivr_id = aggregation.ivr_id
LEFT
JOIN document
    ON ivr_detail.calls_ivr_id = document.calls_ivr_id
LEFT 
JOIN cust_phone
   ON ivr_detail.calls_ivr_id = cust_phone.calls_ivr_id
LEFT
JOIN billing
   ON ivr_detail.calls_ivr_id = billing.calls_ivr_id
LEFT
JOIN masiva
   ON ivr_detail.calls_ivr_id = masiva.calls_ivr_id
LEFT
JOIN info_by_phone
   ON ivr_detail.calls_ivr_id = info_by_phone.calls_ivr_id
LEFT
JOIN info_by_id
   ON ivr_detail.calls_ivr_id = info_by_id.calls_ivr_id
LEFT
JOIN twenty_four_h
   ON ivr_detail.calls_ivr_id = twenty_four_h.ivr_id
