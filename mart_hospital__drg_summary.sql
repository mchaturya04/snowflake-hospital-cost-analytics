/*
    Mart model: mart_hospital__drg_summary
    ---------------------------------------
    Purpose  : Diagnosis-level rollup — which conditions cost the most, and how much
               do hospitals bill vs. what Medicare actually pays per condition.
    Source   : stg_hospital__charges
    Grain    : One row per DRG code
*/

select
    drg_code,
    drg_description,
    count(distinct provider_id)                             as num_hospitals_offering,
    sum(total_discharges)                                   as total_national_discharges,
    round(avg(avg_billed_amount), 0)                        as avg_billed_amount,
    round(avg(avg_medicare_payment), 0)                     as avg_medicare_payment,
    round(avg(billing_gap), 0)                              as avg_billing_gap,
    round(avg(billed_to_paid_ratio), 2)                     as avg_billed_to_paid_ratio,

    -- Rank by total national volume (most common procedures)
    rank() over (order by sum(total_discharges) desc)       as volume_rank,

    -- Rank by average billed amount (most expensive procedures)
    rank() over (order by avg(avg_billed_amount) desc)      as cost_rank

from {{ ref('stg_hospital__charges') }}

group by drg_code, drg_description
order by avg_billed_amount desc
