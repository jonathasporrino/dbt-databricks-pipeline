{% set extension_keywords = [
    "No degree mentioned", 
    "Health insurance", 
    "Dental insurance", 
    "Paid time off" ] 
    %}

with source as (
  select *
  from {{ source('jobs', 'raw_job_postings') }}
  where error is not true
),
parsed as (
    select 
        *,
        from_json(job_extensions_raw, 'array<string>') as job_extensions
    from source
),
cleaned as(
    select 
        job_id,
        job_title,
        trim(company_name) as company_name,
        job_location,
        regexp_replace(job_via, '^via ', '') as source_platform,
        job_posted_at,
        job_schedule_type,
        job_work_from_home,
        job_extensions_raw,
        search_time as searched_at,
        search_date,
        search_term,
        search_location,
        job_salary,
        -- lower bound: the number before the en-dash, times its K or M suffix
        {{ parse_salary('min') }} AS salary_min,
        -- upper bound: the same parse on the LAST segment, so a single value is its own range
        {{ parse_salary('max') }} AS salary_max,
        ({{ parse_salary('min') }} + {{ parse_salary('max') }}) / 2 AS salary_avg,
        -- pay period, read off the end of the text: 'a year', 'an hour'
        NULLIF(REGEXP_EXTRACT(job_salary, 'an? (year|hour|month|day|week)$', 1), '') AS salary_period,
        -- currency marker; a salaried row with no marker is stamped USD on purpose
        CASE
            WHEN job_salary IS NOT NULL
            THEN COALESCE(NULLIF(TRIM(REGEXP_EXTRACT(job_salary, '^([^0-9]+)', 1)), ''), 'USD')
        END AS salary_currency,
        {% for keyword in extension_keywords -%}
        array_contains(
            job_extensions,
            "{{keyword}}"
            ) as has_{{ slugify(keyword) }}
        {{- "," if not loop.last }}
        {% endfor %}

    from parsed
)
    select *
    from cleaned