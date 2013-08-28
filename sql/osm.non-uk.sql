drop table if exists non_uk;
create table non_uk as
select way_id as id from way_tags where k in ('name','name:uk') group by way_id having count(distinct v)>1;