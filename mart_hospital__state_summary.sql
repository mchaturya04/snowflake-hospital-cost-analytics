/*
    Mart model: mart_hospital__state_summary
    -----------------------------------------
    Purpose  : State-level rollup of Medicare hospital billing and payment data.
               This is the primary model for geographic analysis and dashboards.
    Source   : stg_hospital__charges
    Grain    : One row per US state
    Key metrics:
        - avg_billed_amount       : how much hospitals in this state bill on average
        - avg_medicare_payment    : how much Medicare pays on average
        - avg_billed_to_paid_ratio: how aggressively hospitals bill vs what they receive
        - total_patients          : total Medicare discharges (volume indicator)
*/

select
    state,
    count(distinct provider_id)                             as total_hospitals,
    sum(total_discharges)                                   as total_patients,
    round(avg(avg_billed_amount), 0)                        as avg_billed_amount,
    round(avg(avg_medicare_payment), 0)                     as avg_medicare_payment,
    round(avg(billing_gap), 0)                              as avg_billing_gap,
    round(avg(billed_to_paid_ratio), 2)                     as avg_billed_to_paid_ratio,

    -- Rank states by billing aggressiveness (1 = most aggressive)
    rank() over (order by avg(billed_to_paid_ratio) desc)   as billing_ratio_rank

from {{ ref('stg_hospital__charges') }}

group by state
order by avg_billed_to_paid_ratio desc
