select '{';
select '"type": "FeatureCollection",';
select '"errorDescr": "Multipolygon end-node",';

select '"features": [';
with a as (
  select rm.relation_id,rm.member_id as way_id
  from relation_tags rt
    inner join relation_members rm on rm.relation_id=rt.relation_id and rm.member_type='W'
  where rt.k='type' and rt.v in ('multipolygon','boundary')
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
select '{"type":"Feature","properties":{"josm":"r'||d.relation_id||',n'||node_id||'"},"geometry":'||st_asgeojson(n.geom,5)||'},'
from d
  inner join nodes n on n.id=node_id
  inner join regions r on r.relation_id=d.relation_id or _st_contains(r.linestring, n.geom)
order by 1;

select '{"type":"Feature"}';
select ']}';
