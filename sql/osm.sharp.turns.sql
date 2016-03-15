select '{';
select '"type": "FeatureCollection",';
select '"errorDescr": "Sharp turn",';
select '"features": [';

drop type if exists node_info;
create type node_info as (sequence_id int, id bigint, geom geometry);

with tab as (
  select h.id,array_agg((wn.sequence_id,n.id,n.geom)::node_info order by wn.sequence_id) arr
  from highways h
    inner join way_nodes wn on wn.way_id=h.id
    inner join nodes n on n.id=wn.node_id
  group by h.id
)
select '{"type":"Feature","properties":{"josm":"w'||tab.id||',n'||tab.arr[n1.sequence_id+2].id||'"},"geometry":'||st_asgeojson(tab.arr[n1.sequence_id+2].geom,5)||'},'
from tab, unnest(tab.arr) as n1
where tab.arr[n1.sequence_id+3] is not null
  and abs(ST_Azimuth(n1.geom,tab.arr[n1.sequence_id+2].geom)-ST_Azimuth(tab.arr[n1.sequence_id+2].geom,tab.arr[n1.sequence_id+3].geom))/pi() between 0.95 and 1.05
  and tab.arr[n1.sequence_id+3].sequence_id=n1.sequence_id+2;

with tab as (
  select h.way_id id,array_agg((wn.sequence_id,n.id,n.geom)::node_info order by wn.sequence_id) arr
  from way_tags h
    inner join way_nodes wn on wn.way_id=h.way_id
    inner join nodes n on n.id=wn.node_id
  where k='waterway' and v in ('river','stream','canal')
  group by h.way_id
)
select '{"type":"Feature","properties":{"josm":"w'||tab.id||',n'||tab.arr[n1.sequence_id+2].id||'"},"geometry":'||st_asgeojson(tab.arr[n1.sequence_id+2].geom,5)||'},'
from tab, unnest(tab.arr) as n1
where tab.arr[n1.sequence_id+3] is not null
  and abs(ST_Azimuth(n1.geom,tab.arr[n1.sequence_id+2].geom)-ST_Azimuth(tab.arr[n1.sequence_id+2].geom,tab.arr[n1.sequence_id+3].geom))/pi() between 0.95 and 1.05
  and tab.arr[n1.sequence_id+3].sequence_id=n1.sequence_id+2;

select '{"type":"Feature"}';
select ']}';
