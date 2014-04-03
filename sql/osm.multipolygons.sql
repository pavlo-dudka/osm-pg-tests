select '{';
select '"type": "FeatureCollection",';
select '"features": [';
with a as (
select rm.relation_id,rm.member_id as way_id
from relation_tags rt
inner join relation_members rm on rm.relation_id=rt.relation_id and rm.member_type='W'
where rt.k='type' and rt.v in ('multipolygon','boundary')
  and exists(select * from relation_tags rt2 where rt2.relation_id=rt.relation_id and rt2.k in ('natural','landuse','place','waterway','boundary'))
  and rt.relation_id not in (59065,1515474,2033253,3023473)
),
b as
(
select max(sequence_id) as max_sequence_id, a.way_id
from way_nodes wn, a
where wn.way_id=a.way_id
group by a.way_id
),
c as 
(
select a.relation_id,wn.node_id
from a,way_nodes wn
where wn.way_id=a.way_id and wn.sequence_id=0
union all
select a.relation_id,wn.node_id
from a,b,way_nodes wn
where a.way_id=b.way_id
and wn.way_id=a.way_id and wn.sequence_id=b.max_sequence_id
)
select '{"type":"Feature","properties":{"josm":"r'||c.relation_id||',n'||node_id||'"},"geometry":'||st_asgeojson(min(n.geom),5)||'},'
from c
inner join nodes n on n.id=node_id
left  join regions r on r.relation_id=c.relation_id or st_contains(r.linestring, n.geom)
where r.relation_id is not null
group by c.relation_id,node_id
having count(*) not in (2,4)
order by c.relation_id,node_id;

select '{"type":"Feature"}';
select ']}';
