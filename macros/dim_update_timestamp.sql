{% macro dim_update_timestamp(dim_name, inc_prefix, t2_prefix, source_prefix) %}
    {% if is_incremental() -%}
    {#- Incremental Run Case -#}
        case when ({{t2_prefix}}.dbt_valid_to is null 
                    and {{inc_prefix}}.t1_key != {{source_prefix}}.t1_key) then convert_timezone('America/Montreal',current_timestamp())
             when ({{inc_prefix}}.{{dim_name}}_key is not null) then {{inc_prefix}}.dbt_updated_at
             else convert_timezone('America/Montreal',{{t2_prefix}}.dbt_updated_at::timestamp) end as dbt_updated_at
    {%- else %}
    {#- Initial Run Case -#}
        case when ({{t2_prefix}}.dbt_valid_to is null 
                    and {{t2_prefix}}.t1_key != {{source_prefix}}.t1_key ) then convert_timezone('America/Montreal',current_timestamp())
             else convert_timezone('America/Montreal',{{t2_prefix}}.dbt_updated_at::timestamp) end as dbt_updated_at
    {%- endif %}
{% endmacro %}


{#
	Dans tous les cas, le but est de mettre à jour le dbt_update_dt de la dernière ligne de dim (celle avec dbt_valid_to is null). Ainsi :
		- si ({{inc_prefix}}.dbt_valid_to is null et changement de clé (une des colonnes de SCD 1 a changé) : on prend current_timestamp()
		- si la clé dans la DIM existe alors on prend la valeur dans la DIM (signifie que la ligne de SCD 2 est déjà présent dans la DIM = rien à faire)
		- sinon, on est dans le cas où la DIM n''a pas la clé de SCD 2 = on la prend dans le snapshot.
		
	Dans le cas d''un initial run : la DIM n''existe pas encore. 2 cas :
		- on prend  current_timestamp() si détection d''un SCD1
		- on prend la valeur dans le snapshot dans le cas d''un SCD2
#}