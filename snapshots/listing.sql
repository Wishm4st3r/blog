{% snapshot listing %}

{{
  config(
    target_schema = 'dbt_snapshot',
    unique_key = 'list_id',
    strategy = 'check',
    check_cols = ['seller_id','event_id']
    )
}}

{%- set t1_cols = ['total_price'] -%}

select list_id::varchar || '-' || to_char(convert_timezone('America/Montreal',current_timestamp()),'YYYYMMDDHH24MISS') as listing_key,
        *,
        {{ dbt_utils.generate_surrogate_key(t1_cols) }} as t1_key
from {{ source('dbt_raw', 'listing') }}

{% endsnapshot %}