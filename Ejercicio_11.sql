--11. Generar los campos repeated_phone_24H, cause_recall_phone_24H

SELECT ivr_id
     , phone_number
    -- , start_date
    -- , LAG(start_date)
    --    OVER (PARTITION BY phone_number ORDER BY start_date) AS start_date_lag
    -- , DATE_DIFF(start_date, LAG(start_date) OVER (PARTITION BY phone_number ORDER BY start_date), DAY)
     , IF(DATE_DIFF(start_date, LAG(start_date) OVER (PARTITION BY phone_number ORDER BY start_date), DAY) <= 1, 1, 0)  AS repeated_phone_24H
    -- , LEAD(start_date)
    --    OVER (PARTITION BY phone_number ORDER BY start_date) AS start_date_lead
    -- , DATE_DIFF(LEAD(start_date) OVER (PARTITION BY phone_number ORDER BY start_date), start_date, DAY)--
     , IF(DATE_DIFF(LEAD(start_date) OVER (PARTITION BY phone_number ORDER BY start_date), start_date, DAY) <= 1, 1, 0) AS cause_recall_phone_24H

FROM `keepcoding.ivr_calls`
ORDER BY phone_number, start_date
