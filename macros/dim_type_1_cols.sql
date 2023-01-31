{% macro dim_type_1_cols(t1_cols, dim_name, inc_prefix, t2_prefix, source_prefix) %}
    {% for col in t1_cols -%}
        {% if is_incremental() -%}
        {#- Incremental Run case -#}
            case when ({{inc_prefix}}.dbt_valid_to is null  
                        and {{inc_prefix}}.t1_key != {{source_prefix}}.t1_key) then {{source_prefix}}.{{col}}
                when ({{inc_prefix}}.{{ dim_name }}_key is not null) then {{inc_prefix}}.{{col}}
                else {{t2_prefix}}.{{col}} end as {{col}} {%- if not loop.last -%},{%- endif -%}
        {%- else %} 
        {#- Initial Run Case -#}
            case when ({{t2_prefix}}.dbt_valid_to is null 
                        and {{t2_prefix}}.t1_key != {{source_prefix}}.t1_key ) then {{source_prefix}}.{{col}}
                else {{t2_prefix}}.{{col}} end as {{col}} {%- if not loop.last -%},{%- endif -%}
        {%- endif %}
    {% endfor -%}
{% endmacro %}

{#
	Dans tous les cas, le but est de mettre à jour la dernière ligne de dim (celle avec dbt_valid_to is null). Ainsi :
		- si ({{inc_prefix}}.dbt_valid_to is null et changement de clé (une des colonnes de SCD 1 a changé) : on prend la valeur selon la source (contenant le changement)
		- si la clé dans la DIM existe alors on prend la valeur dans la DIM (signifie que la ligne de SCD 2 est déjà présent dans la DIM = rien à faire)
		- sinon, on est dans le cas où la DIM n'a pas la clé de SCD 2 = on la prend dans le snapshot.
		
	Dans le cas d'un initial run : la DIM n'existe pas encore. 2 cas :
		- on prend les valeurs dans la source si détection d'un SCD1
		- on prend la valeur dans le snapshot dans le cas d'un SCD2
#}