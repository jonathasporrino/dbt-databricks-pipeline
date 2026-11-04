with source as (
  select *
  from {{ source('jobs', 'raw_job_postings') }}
  where error is not true
),
cleaned as(
    select 
        job_id,
        job_title,
        trim(company_name) as company_name,
        job_location,
        regexp_replace(job_via, '^via ', ''),
        job_posted_at,
        job_salary,
        job_schedule_type,
        job_work_from_home,
        job_extensions_raw,
        search_time as searched_at,
        search_date,
        search_term,
        search_location
    from source
)
    select *
    from cleaned