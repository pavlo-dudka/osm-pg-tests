select '{';
select '"type": "FeatureCollection",';
select '"errorDescr": "Railway sharp turn",';
select '"features": [';

drop type if exists rw_node_info;
create type rw_node_info as (sequence_id int, id bigint, geom geometry);

with tab as (
  select h.way_id id,array_agg((wn.sequence_id,n.id,n.geom)::rw_node_info order by wn.sequence_id) arr
  from way_tags h
    inner join way_nodes wn on wn.way_id=h.way_id
    inner join nodes n on n.id=wn.node_id
  where k='railway' and v not in ('station','halt','platform','tram_stop','subway_entrance','engine_shed','depot','yard','roundhouse','crossing_box','buffer_stop','yes','ventilation_shaft','signal_box')
    and not exists(select * from way_tags wta where wta.way_id=h.way_id and wta.k='area' and wta.v='yes')
  group by h.way_id
),
tab2 as (
  select tab.id way_id,
         tab.arr[n1.sequence_id+2].id node_id,
         round(180*(1-abs(1-abs(ST_Azimuth(n1.geom,tab.arr[n1.sequence_id+2].geom)-ST_Azimuth(tab.arr[n1.sequence_id+2].geom,tab.arr[n1.sequence_id+3].geom))/pi()))::numeric,2) angle,
         tab.arr[n1.sequence_id+2].geom geom
  from tab, unnest(tab.arr) as n1
  where tab.arr[n1.sequence_id+3] is not null
    and abs(ST_Azimuth(n1.geom,tab.arr[n1.sequence_id+2].geom)-ST_Azimuth(tab.arr[n1.sequence_id+2].geom,tab.arr[n1.sequence_id+3].geom))/pi() between 1./3 and 5./3
    and tab.arr[n1.sequence_id+3].sequence_id=n1.sequence_id+2
    and not exists(select * from cross_way_nodes_rail where tab.id in (way_id_1,way_id_2) and tab.arr[n1.sequence_id+2].id=any(node_ids)))
select '{"type":"Feature","properties":{"josm":"w'||way_id||',n'||node_id||'"},"angle":"'||angle||'","geometry":'||st_asgeojson(geom,5)||'},'
from tab2
where node_id not in (1231559718)
order by angle desc;

select '{"type":"Feature"}';
select ']}';
