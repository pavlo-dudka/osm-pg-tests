set client_min_messages to warning;
drop table if exists end_nodes;
create table end_nodes as
with 
a as (
  select max(sequence_id) as max_sequence_id,wn.way_id,min(t.layer) as layer
  from way_nodes wn
  inner join highways t on t.id=wn.way_id
  group by wn.way_id),
b as (
  select a.layer,wn.way_id,n.geom,n.id
  from a
  inner join way_nodes wn on wn.way_id=a.way_id and wn.sequence_id in (0,a.max_sequence_id)
  inner join nodes n on n.id=wn.node_id
  where (select count(*) from way_nodes wn2 where wn.node_id=wn2.node_id group by node_id)=1
  and not exists(select * from node_tags nt where nt.node_id=n.id and nt.k='noexit' and nt.v in ('yes','true','1'))
  and not exists(select * from node_tags nt where nt.node_id=n.id and nt.k='highway' and nt.v='turning_circle')
  and not exists(select * from way_tags wt where wt.way_id=wn.way_id and wt.k='highway' and wt.v in ('service','platform'))
  and n.id not in (546405082,546351032,2324552116,1791825888,1616608260,1059524279,1452513637,1452513638,1822002730,1822002733,2394431921,2425800793)
)
select * from b;

select '{';
select '"type": "FeatureCollection",';
--select '"changeset": "'||max(changeset_id)||'",' from nodes;
--select '"tstamp": "'||max(tstamp)||'",' from nodes;
select '"features": [';
select '{"type":"Feature","id":"'||b.id||'","properties":{"josm":"n'||b.id||','||string_agg('w'||t.id,',' order by t.id)||'"},"geometry":'||st_asgeojson(b.geom,5)||'},'
from end_nodes b
inner join highways t on t.id<>b.way_id and t.layer=b.layer and st_dwithin(b.geom,t.linestring,0.01) and st_distance_sphere(b.geom,t.linestring) < 5
group by b.id,b.geom
order by b.id;
select ']}';