{{ config(severity='warn') }}

select
    job_id,
    search_term,
    job_title,
    salary_min,
    salary_max,
    salary_period,
    salary_currency
from dev.staging.stg_job_postings
where salary_period = 'year'
    and coalesce(salary_max, salary_min) >= 1000000   
    and salary_currency = 'USD'