with sources as (
    select *
    from {{ source('jobs', 'raw_job_skills') }}
),
cleaned as (
    select
        job_id,
        skill_id,
        trim(skill_keyword) as skill_keyword
    from sources
)

select *
from cleaned