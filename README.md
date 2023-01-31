Suppose you are in a database named BLOG_DBT.

# Examples of the 1st part can be execute with

-- Create schemas
create or replace schema BLOG_DBT.DBT_RAW;
create or replace schema BLOG_DBT.DBT_SNAPSHOT;
create or replace schema BLOG_DBT.DBT_MDL;

use schema BLOG_DBT.DBT_RAW;

-- Create table for strategy tests
create table test_strategy(
    id number
    ,status string
    ,updated_at timestamp
);

-- Test with a 1st value
insert into test_strategy
values(1, 'pending', '2023-01-31');

-- Execute dbt command in dbt
-- dbt snapshot -s test_strategy
select * from BLOG_DBT.DBT_SNAPSHOT.TEST_STRATEGY;

-- Test with a 2nd value
update test_strategy
set status = 'shipped', updated_at = '2023-02-01'
where id = 1;

-- Execute dbt command in dbt
-- dbt snapshot -s test_strategy
select * from BLOG_DBT.DBT_SNAPSHOT.TEST_STRATEGY;



# Examples of the 2nd part can be execute with

-- Create source objects
use schema BLOG_DBT.DBT_RAW;

create table listing(
    list_id number
    ,seller_id number
    ,event_id number
    ,total_price number
);

-- Insert value for the first step
INSERT INTO listing 
VALUES(776, 20797, 1811, 2394);

INSERT INTO listing 
VALUES(5736, 32170, 1221, 1768);

INSERT INTO listing 
VALUES(6635, 30023, 2426, 400);

-- Execute dbt command in dbt
-- dbt snapshot -s listing
-- dbt build -s dim_listing

-- Look at the results in Snowflake :
select * from dbt_snapshot.listing;
select * from dbt_mdl.dim_listing;

-- Insert value for the second step
update listing
set seller_id = 666
where list_id=776;

-- Execute dbt command in dbt
-- dbt snapshot -s listing
-- dbt build -s dim_listing

-- Look at the results in Snowflake :
select * from dbt_snapshot.listing;
select * from dbt_mdl.dim_listing;

-- Insert value for the third step
update listing
set total_price = 666
where list_id=776;

-- Execute dbt command in dbt
-- dbt snapshot -s listing
-- dbt build -s dim_listing

-- Execute dbt command in dbt
select * from dbt_snapshot.listing;
select * from dbt_mdl.dim_listing;

