set client_min_messages to warning;
drop table if exists railway_end_nodes;
create unlogged table railway_end_nodes tablespace osmspace as
select h.layer,h.id as way_id,n.geom,n.id
from railways h
inner join nodes n on n.id in (h.node0, h.node1)
inner join way_tags wt on wt.way_id=h.id and wt.k='usage' and wt.v='main'
where (select count(*) from way_nodes wn2,railways h2 inner join way_tags wt2 on wt2.way_id=h2.id and wt2.k='usage' and wt2.v='main' where wn2.node_id=n.id and wn2.way_id=h2.id)=1
  and h.node0<>h.node1;
create index idx_railway_end_nodes_geom on railway_end_nodes using gist(geom);

select '{';
select '"type": "FeatureCollection",';
select '"errorDescr": "Dead node",';
select '"features": [';

select '{"type":"Feature","id":"'||b.id||'","properties":{"josm":"n'||b.id||',w'||h.id||'","region":"'||r.name||'"},"geometry":'||st_asgeojson(b.geom,5)||'},'
from railway_end_nodes b
  inner join railways h on b.way_id=h.id
  inner join regions r on _st_containsproperly(r.linestring,b.geom)
where b.id not in (4013083113)
order by b.id;

select '{"type":"Feature"}';
select ']}';