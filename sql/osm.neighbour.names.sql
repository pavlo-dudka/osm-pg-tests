select 'Nodes:';
with t as (
select w1.id, wt1.v as v1, wt2.v as v2, wt3.v as v3, wt2.way_id as road_id, wt3.k
from 
nodes w1 
  inner join node_tags wt1 on wt1.node_id=w1.id and wt1.k='addr:street'
  inner join node_tags wth on wth.node_id=w1.id and wth.k='addr:housenumber',
highways w2 
  inner join way_tags wt2 on wt2.way_id=w2.id and wt2.k='name'
  inner join way_tags wt3 on wt3.way_id=w2.id and wt3.k like '%name%'
where
 (position(lower(wt1.v) in lower(wt3.v))>0
  or position(lower(wt3.v) in lower(wt1.v))>0 and position('/' in wt1.v)=0 and position(';' in wt1.v)=0
  or levenshtein_less_equal(lower(wt1.v),lower(wt3.v),4)<4 and wt3.k not like 'old_name%'
  )
and st_dwithin(w1.geom,w2.linestring,0.01)
and not exists(select * from relation_tags rt,relation_members rm where rt.relation_id=rm.relation_id and rm.member_id=w1.id and rt.k='type' and rt.v='associatedStreet')
), addr_errors as (
select t.id, v1 as oldv, string_agg(distinct v2, ';' order by v2) as newv, array_agg(distinct road_id) as road_ids, min(k) as k
from t
group by 1,2
having not(v1 = any(array_agg(v2))))
select r.name, k, oldv, newv, string_agg(distinct a.id::text,',' order by a.id::text), array_to_string(array_agg(distinct road_id), ',') as road_ids
from addr_errors a
  inner join nodes w on w.id=a.id
  left join regions r on st_contains(r.linestring,w.geom),
  unnest(road_ids) road_id
group by 1,2,3,4
order by 1,2,3,4;

select '';
select 'Ways:';
with t as (
select w1.id, wt1.v as v1, wt2.v as v2, wt3.v as v3, wt2.way_id as road_id, wt3.k
from 
ways w1 
  inner join way_tags wt1 on wt1.way_id=w1.id and wt1.k='addr:street'
  inner join way_tags wth on wth.way_id=w1.id and wth.k='addr:housenumber',
highways w2 
  inner join way_tags wt2 on wt2.way_id=w2.id and wt2.k='name'
  inner join way_tags wt3 on wt3.way_id=w2.id and wt3.k like '%name%'
where
 (position(lower(wt1.v) in lower(wt3.v))>0
  or position(lower(wt3.v) in lower(wt1.v))>0 and position('/' in wt1.v)=0 and position(';' in wt1.v)=0
  or levenshtein_less_equal(lower(wt1.v),lower(wt3.v),4)<4 and wt3.k not like 'old_name%'
  )
and st_dwithin(w1.linestring,w2.linestring,0.01)
and not exists(select * from relation_tags rt,relation_members rm where rt.relation_id=rm.relation_id and rm.member_id=w1.id and rt.k='type' and rt.v='associatedStreet')
), addr_errors as (
select t.id, v1 as oldv, string_agg(distinct v2, ';' order by v2) as newv, array_agg(distinct road_id) as road_ids, min(k) as k
from t
group by 1,2
having not(v1 = any(array_agg(v2))))
select r.name, k, oldv, newv, string_agg(distinct a.id::text,',' order by a.id::text), array_to_string(array_agg(distinct road_id), ',') as road_ids
from addr_errors a
  inner join ways w on w.id=a.id
  left join regions r on st_contains(r.linestring,w.linestring),
  unnest(road_ids) road_id
group by 1,2,3,4
order by 1,2,3,4;

select '';
select 'Relations:';
with t as (
select w1.id, wt1.v as v1, wt2.v as v2, wt3.v as v3, wt2.way_id as road_id, wt3.k
from 
relations w1 
  inner join relation_tags wt1 on wt1.relation_id=w1.id and wt1.k='addr:street'
  inner join relation_tags wth on wth.relation_id=w1.id and wth.k='addr:housenumber',
highways w2 
  inner join way_tags wt2 on wt2.way_id=w2.id and wt2.k='name'
  inner join way_tags wt3 on wt3.way_id=w2.id and wt3.k like '%name%'
where
 (position(lower(wt1.v) in lower(wt3.v))>0
  or position(lower(wt3.v) in lower(wt1.v))>0 and position('/' in wt1.v)=0 and position(';' in wt1.v)=0
  or levenshtein_less_equal(lower(wt1.v),lower(wt3.v),4)<4 and wt3.k not like 'old_name%'
  )
and st_dwithin(w1.linestring,w2.linestring,0.01)
and not exists(select * from relation_tags rt,relation_members rm where rt.relation_id=rm.relation_id and rm.member_id=w1.id and rt.k='type' and rt.v='associatedStreet')
), addr_errors as (
select t.id, v1 as oldv, string_agg(distinct v2, ';' order by v2) as newv, array_agg(distinct road_id) as road_ids, min(k) as k
from t
group by 1,2
having not(v1 = any(array_agg(v2))))
select r.name, k, oldv, newv, string_agg(distinct a.id::text,',' order by a.id::text), array_to_string(array_agg(distinct road_id), ',') as road_ids
from addr_errors a
  inner join relations w on w.id=a.id
  left join regions r on st_contains(r.linestring,w.linestring),
  unnest(road_ids) road_id
group by 1,2,3,4
order by 1,2,3,4;


select '';
select 'Highways:';
select distinct r.name,h1.id,h2.id,wt1.k,wt1.v name1,wt2.v name2
from highways h1
inner join way_tags wt1 on wt1.way_id=h1.id and wt1.k in ('name','name:uk','name:ru')
inner join way_tags wt1m on wt1m.way_id=h1.id and wt1m.k in ('name','name:uk','name:ru','name:en')
left join regions r on _st_contains(r.linestring,h1.linestring)
,
highways h2
inner join way_tags wt2 on wt2.way_id=h2.id and wt2.k in ('name','name:uk','name:ru')
inner join way_tags wt2m on wt2m.way_id=h2.id and wt2m.k in ('name','name:uk','name:ru','name:en')
where st_dwithin(h1.linestring,h2.linestring,0.001)
  and wt1m.v=wt2m.v
  and h1.id<h2.id and wt1.v<>wt2.v and wt1.k=wt2.k
  and not exists(select rm.relation_id from relation_members rm, relation_tags rt, relation_tags rt2 where rm.relation_id=rt.relation_id and rm.relation_id=rt2.relation_id and rm.member_id in (h1.id,h2.id) and rt.k=wt1.k and rt2.k='type' and rt2.v='associatedStreet' group by rm.relation_id having count(*)=2)
order by 1,2,3;