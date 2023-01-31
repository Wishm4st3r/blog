{% snapshot test_strategy %}

{% set new_schema = 'DBT_SNAPSHOT' %}

{{
    config(
      target_database='BLOG_DBT',
      target_schema=new_schema,
      unique_key='id',

      strategy='mystrategy',
      check_cols=['status'],
    )
}}

select * from dbt_raw.test_strategy

{% endsnapshot %}