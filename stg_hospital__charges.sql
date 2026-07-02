/*
    Staging model: stg_hospital__charges
    ------------------------------------
    Purpose  : Clean, rename, and enrich the raw CMS Medicare hospital charge data.
    Source   : HOSPITAL_PROJECT.RAW.RAW_HOSPITAL_CHARGES
    Grain    : One row per hospital (provider_id) per diagnosis (drg_code)
    Notes    : - Column names are standardized from CMS abbreviations to readable names
               - Two derived metrics (billing_gap, billed_to_paid_ratio) are calculated
                 once here so every downstream model uses the same definition
               - NULLIF prevents divide-by-zero errors on avg_medicare_payment
*/

select
    -- Hospital identifiers
    rndrng_prvdr_ccn                                                    as provider_id,
    rndrng_prvdr_org_name                                               as hospital_name,
    rndrng_prvdr_city                                                   as city,
    rndrng_prvdr_state_abrvtn                                           as state,
    rndrng_prvdr_zip5                                                   as zip_code,
    rndrng_prvdr_ruca_desc                                              as area_type,

    -- Diagnosis
    drg_cd                                                              as drg_code,
    drg_desc                                                            as drg_description,

    -- Volume
    tot_dschrgs                                                         as total_discharges,

    -- Financials
    avg_submtd_cvrd_chrg                                                as avg_billed_amount,
    avg_tot_pymt_amt                                                    as avg_total_payment,
    avg_mdcr_pymt_amt                                                   as avg_medicare_payment,

    -- Derived metrics
    avg_submtd_cvrd_chrg - avg_mdcr_pymt_amt                           as billing_gap,
    round(
        avg_submtd_cvrd_chrg / nullif(avg_mdcr_pymt_amt, 0), 2
    )                                                                   as billed_to_paid_ratio

from {{ source('raw_hospital', 'raw_hospital_charges') }}

where
    rndrng_prvdr_ccn    is not null   -- must have a valid hospital identifier
    and drg_cd          is not null   -- must have a valid diagnosis code
