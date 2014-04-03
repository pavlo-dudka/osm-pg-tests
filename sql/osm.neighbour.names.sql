set client_min_messages to warning;
drop table if exists addr_errors;
create table addr_errors as
with t as (
select w1.id, wt1.v as v1, wt2.v as v2, wt3.v as v3, wt2.way_id as road_id
from 
ways w1 
  inner join way_tags wt1 on wt1.way_id=w1.id and wt1.k in ('name','addr:street')
  left  join highways h1  on h1.id=w1.id,
highways w2 
  inner join way_tags wt2 on wt2.way_id=w2.id and wt2.k='name'
  left  join way_tags wt3 on wt3.way_id=w2.id and wt3.k='name:ru'
where
 (position(lower(wt1.v) in lower(wt2.v))>0
  or wt1.k='addr:street' and position(lower(wt2.v) in lower(wt1.v))>0 and position('/' in wt1.v)=0 and position(';' in wt1.v)=0
  or wt1.k='addr:street' and levenshtein_less_equal(lower(wt1.v),lower(wt2.v),4)<4

  or position(lower(wt1.v) in lower(wt3.v))>0
  or wt1.k='addr:street' and position(lower(wt3.v) in lower(wt1.v))>0 and position('/' in wt1.v)=0 and position(';' in wt1.v)=0
  or wt1.k='addr:street' and levenshtein_less_equal(lower(wt1.v),lower(wt3.v),4)<4
  )
and st_dwithin(w1.linestring,w2.linestring,0.01)
--and wt2.v not like '% улица'
and (wt1.k='name' and h1.id is not null or wt1.k='addr:street' and h1.id is null))
select t.id,v1 as oldv,string_agg(distinct v2, ';  ' order by v2) as newv
from t
group by 1,2
having not(v1 = any(array_agg(v2)));

select 'Buildings:';
select r.name,oldv,newv,string_agg(a.id::text,',' order by a.id) 
from addr_errors a
  inner join ways w on w.id=a.id
  left join regions r on st_intersects(r.linestring,w.linestring)
group by 1,2,3
order by 1,2,3;


select '';
select 'Highways:';
select distinct h1.id,h2.id,wt1.k,wt1.v name1,wt2.v name2
from highways h1
inner join way_tags wt1 on wt1.way_id=h1.id and wt1.k in ('name','name:uk','name:ru')
inner join way_tags wt1m on wt1m.way_id=h1.id and wt1m.k in ('name','name:uk','name:ru')
,
highways h2
inner join way_tags wt2 on wt2.way_id=h2.id and wt2.k in ('name','name:uk','name:ru')
inner join way_tags wt2m on wt2m.way_id=h2.id and wt2m.k in ('name','name:uk','name:ru')
where st_dwithin(h1.linestring,h2.linestring,0.0003)
  and wt1m.v=wt2m.v
  and h1.id<h2.id and wt1.v<>wt2.v and wt1.k=wt2.k
order by 1,2;