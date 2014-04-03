/*select wt.v
from highways h
inner join way_tags wt on wt.way_id=h.id and wt.k='name' and wt.v not like '% %'
inner join streets s on s.ru=wt.v;*/

delete from way_tags wt where k='addr:housename' and way_id in (
with t as (
select way_id,
  min(case when k='addr:housenumber' then v end) ah,
  min(case when k='addr:housename' then v end) n,
  array_agg(k) arr
from way_tags
group by way_id 
having array['name','addr:city','addr:housename','addr:housenumber','addr:street','addr:postcode','building','building:levels','building:material','source','height','nadoloni:id','source_ref'] @> array_agg(k) and count(distinct k)>count(distinct v)
)
select way_id from t where ah=n);

delete from way_tags wt where k='name' and way_id in (
with t as (
select way_id,
  min(case when k='addr:housenumber' then v end) ah,
  min(case when k='name' then v end) n,
  array_agg(k) arr
from way_tags
group by way_id 
having array['name','addr:city','addr:housename','addr:housenumber','addr:street','addr:postcode','building','building:levels','building:material','source','height','nadoloni:id','source_ref'] @> array_agg(k) and count(distinct k)>count(distinct v)
)
select way_id from t where ah=n)

