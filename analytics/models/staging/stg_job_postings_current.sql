{{ config(
    materialized='ephemeral'
) 
}}

select
*
from {{ ref('stg_job_postings') }}
where search_date <= cast('{{ var('as_of', run_started_at) }}' as date)
qualify row_number() over (
    partition by job_id     
    order by searched_at desc
    ) = 1