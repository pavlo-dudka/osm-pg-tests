set client_min_messages to warning;
drop table if exists end_nodes;
create table end_nodes as
select h.layer,h.id as way_id,n.geom,n.id
from highways h
inner join nodes n on n.id in (h.node0, h.node1)
where (select count(*) from way_nodes wn2,highways h2 where wn2.node_id=n.id and wn2.way_id=h2.id)=1
  and not exists(select * from node_tags nt where nt.node_id=n.id and nt.k='noexit' and nt.v in ('yes','true','1'))
  and not exists(select * from node_tags nt where nt.node_id=n.id and nt.k='highway' and nt.v='turning_circle')
  and not exists(select * from way_tags wt where wt.way_id=h.id and wt.k='highway' and wt.v in ('platform','track'))
  and n.id not in (546405082,546351032,2324552116,1791825888,1616608260,1059524279,1452513637,1452513638,1822002730,1822002733,2394431921,2425800793,1467562604,2592172507)
  and h.node0<>h.node1;

select '{';
select '"type": "FeatureCollection",';
--select '"changeset": "'||max(changeset_id)||'",' from nodes;
--select '"tstamp": "'||max(tstamp)||'",' from nodes;
select '"features": [';
select '{"type":"Feature","id":"'||b.id||'","properties":{"josm":"n'||b.id||','||string_agg('w'||t.id,',' order by t.id)||'"},"geometry":'||st_asgeojson(b.geom,5)||'},'
from end_nodes b
inner join highways t on st_dwithin(b.geom,t.linestring,0.01) and t.id<>b.way_id and t.layer=b.layer and st_distance_sphere(b.geom,t.linestring) < (case when t.highway_level='service' then 2 else 5 end)
 left join highways h on h.id=b.way_id 
where _st_intersects(h.linestring,t.linestring)='f'
group by b.id,b.geom
order by b.id;

select '{"type":"Feature"}';
select ']}';