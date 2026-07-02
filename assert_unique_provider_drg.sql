/*
    Singular Test: assert_unique_provider_drg
    ------------------------------------------
    Validates that provider_id + drg_code is truly unique in the staging model.
    This is our assumed composite primary key (one row per hospital per diagnosis).
    If this query returns ANY rows, the test fails — meaning we have duplicates.
*/

select
    provider_id,
    drg_code,
    count(*) as row_count
from {{ ref('stg_hospital__charges') }}
group by provider_id, drg_code
having count(*) > 1
