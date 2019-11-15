select '{';
select '"type": "FeatureCollection",';
select '"errorDescr": "Multipolygon end-node",';

select '"features": [';
with a as (
  select rm.relation_id,rm.member_id as way_id
  from relation_tags rt
    inner join relation_members rm on rm.relation_id=rt.relation_id and rm.member_type='W'
  where rt.k='type' and rt.v in ('multipolygon','boundary')
    and rm.relation_id not in (6366874)
),
c as 
(
  select a.relation_id,
        (select node_id from way_nodes wn where wn.way_id=a.way_id and sequence_id=0) as node_id
  from a
  union all
  select a.relation_id,
        (select node_id from way_nodes wn where wn.way_id=a.way_id order by sequence_id desc limit 1) as node_id
  from a
),
d as (
  select relation_id,node_id
  from c
  group by relation_id,node_id
  having count(*) not in (2,4))
select '{"type":"Feature","properties":{"josm":"r'||d.relation_id||',n'||node_id||'","region":"'||r.name||'"},"geometry":'||st_asgeojson(n.geom,5)||'},'
from d
  inner join nodes n on n.id=node_id
  inner join regions r on d.relation_id=60199 and r.name='Київ' or r.relation_id=d.relation_id or _st_contains(r.linestring, n.geom)
order by 1;

with tab as (
select 'r'||r.id ids,--||string_agg(',w'||w.id, '' order by w.id) ids,
case when r.id in (select relation_id from relation_members group by relation_id having count(*)=1) then 'multipolygon without tags and single member - delete relation' 
     when count(*)>1 and (select min(kv) from (select count(*) kv from way_tags wt where wt.way_id=any(array_agg(w.id)) group by k, v) kv)=count(*) then 'multipolygon without tags, members have identical tags - move tags from ways to relation'
     when count(*)>1 and (select min(kv) from (select count(*) kv from way_tags wt where wt.way_id=any(array_agg(w.id)) group by k, v) kv)<count(*) then 'multipolygon without tags, members have different tags - move appropriate tags to relation'
else null end error,
(select string_agg(kv, ', ' order by kv) from (select k||'='||v kv, count(*) cnt from way_tags wt where wt.way_id=any(array_agg(w.id)) group by k, v) kv where cnt=(select count(*) from relation_members where relation_id=r.id and member_role='outer')) as commonTags,
(select string_agg(kv, ', ' order by kv) from (select k||'='||v kv, count(*) cnt from way_tags wt where wt.way_id=any(array_agg(w.id)) group by k, v) kv where cnt<(select count(*) from relation_members where relation_id=r.id and member_role='outer')) as differTags,
min(st_pointn(w.linestring,2)) as geom
from relations r
inner join relation_tags rt on rt.relation_id=r.id
inner join relation_members rm on rm.relation_id=rt.relation_id and rm.member_role='outer'
left  join ways w on w.id=rm.member_id
where rt.relation_id in (select relation_id from relation_tags rt group by relation_id having count(*)=1 and 'type'=any(array_agg(rt.k)) and 'multipolygon'=any(array_agg(rt.v)))
group by r.id
having sum(case when exists(select * from regions rr where st_contains(rr.linestring, w.linestring)) then 1 else 0 end)>0
order by 1)
select '{"type":"Feature","properties":{"josm":"'||ids||'","error":"'||error||'","region":"'||coalesce(r.name,'')||'"},"geometry":'||st_asgeojson(geom,5)||'},'
from tab 
  left join regions r on st_contains(linestring, geom)
where error is not null;

with tab as (
select r.id relation_id, w1.id way_id_1, w2.id way_id_2, st_intersection(w1.linestring,w2.linestring) intersection
from relations r
inner join relation_tags rt on rt.relation_id=r.id and rt.k='type' and rt.v in ('boundary','multipolygon')
inner join relation_members rm1 on rm1.relation_id=r.id and rm1.member_type='W'
inner join relation_members rm2 on rm2.relation_id=r.id and rm2.member_type='W'
inner join ways w1 on w1.id=rm1.member_id
inner join ways w2 on w2.id=rm2.member_id
where r.id not in (2533235,1455558,6478002)
  and w1.id<w2.id
  and _st_crosses(w1.linestring,w2.linestring) = 't'
  and _st_touches(w1.linestring,w2.linestring) = 'f'
  and st_intersection(w1.linestring,w2.linestring) not in (select (st_dumppoints(w1.linestring)).geom)
)
select '{"type":"Feature","properties":{"josm":"r'||tab.relation_id||',w'||way_id_1||',w'||way_id_2||'","error":"multipolygon members intersect each other","region":"'||coalesce(r.name,'')||'"},"geometry":'||st_asgeojson((select min(geo.geom) from st_dumppoints(intersection) geo),5)||'},'
from tab
  left join regions r on _st_contains(linestring, intersection)
order by 1;

select '{"type":"Feature"}';
select ']}';
