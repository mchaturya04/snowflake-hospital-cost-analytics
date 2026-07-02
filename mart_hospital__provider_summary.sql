/*
    Mart model: mart_hospital__provider_summary
    --------------------------------------------
    Purpose  : Hospital-level rollup — one row per hospital aggregated across all DRGs.
               Used for hospital-to-hospital comparison and outlier detection.
    Source   : stg_hospital__charges
    Grain    : One row per hospital (provider_id)
*/

select
    provider_id,
    hospital_name,
    city,
    state,
    zip_code,
    area_type,

    -- Volume
    count(distinct drg_code)                                as total_drgs_offered,
    sum(total_discharges)                                   as total_patients,

    -- Financials
    round(avg(avg_billed_amount), 0)                        as avg_billed_amount,
    round(avg(avg_medicare_payment), 0)                     as avg_medicare_payment,
    round(avg(billing_gap), 0)                              as avg_billing_gap,
    round(avg(billed_to_paid_ratio), 2)                     as avg_billed_to_paid_ratio,

    -- Identify outliers: flag hospitals billing more than 10x what Medicare pays
    case
        when avg(billed_to_paid_ratio) >= 10 then 'High Outlier'
        when avg(billed_to_paid_ratio) >= 7  then 'Above Average'
        when avg(billed_to_paid_ratio) >= 4  then 'Average'
        else 'Below Average'
    end                                                     as billing_category

from {{ ref('stg_hospital__charges') }}

group by
    provider_id,
    hospital_name,
    city,
    state,
    zip_code,
    area_type

order by avg_billed_to_paid_ratio desc
