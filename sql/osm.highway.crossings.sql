set client_min_messages to warning;
drop table if exists highways;
create table highways as 
select w.id, w.linestring, coalesce(wtl.v,'0') as layer
from ways w
  inner join way_tags wt on wt.way_id=w.id and wt.k='highway' --and wt.v in ('motorway','motorway_link','trunk','trunk_link','primary','primary_link','secondary','secondary_link','tertiary','tertiary_link','unclassified','residential','living_street')
  left join  way_tags wtl on wtl.way_id=w.id and wtl.k='layer'
where not exists(select * from way_tags wta where wta.way_id=w.id and wta.k='area' and wta.v='yes');
create index idx_highways_id on highways(id);
create index idx_highways_linestring on highways using gist(linestring);

drop table if exists cross_way_nodes;
create table cross_way_nodes as
select wn.*,geom as node_geom from way_nodes wn
inner join nodes on node_id=id
where way_id in (select id from highways) and node_id in (select node_id from way_nodes where way_id in (select id from highways) group by node_id having count(distinct way_id)>1);
create index idx_cross_way_nodes_way_id on cross_way_nodes(way_id);

drop table if exists intsc;
create table intsc as
select t1.id as id1,t2.id as id2,
       st_difference(ST_Intersection(t1.linestring,t2.linestring), 
                     ((select st_multi(st_collect(node_geom)) from cross_way_nodes where way_id in (t1.id,t2.id)))) as diff
from highways t1, highways t2
where ST_Intersects(t1.linestring,t2.linestring) = 't' and t1.id<t2.id and t1.layer=t2.layer;  

--drop table if exists highways;
drop table if exists cross_way_nodes;

--create GeoJson
select '{';
select '"type": "FeatureCollection",';
select '"features": [';
select '{"type":"Feature","properties":{"josm":"w'||id1||',w'||id2||'"},"geometry":'||
case when GeometryType(diff)='POINT' then st_asgeojson(diff,5)
     when GeometryType(diff)='LINESTRING' then st_asgeojson(st_pointn(diff, 1), 5)
     when GeometryType(diff)='MULTIPOINT' then st_asgeojson(st_pointn(st_LineFromMultiPoint(diff), 1), 5)
end||
'},'
from intsc
where st_isempty(diff) = 'f' and GeometryType(diff) in ('POINT','MULTIPOINT','LINESTRING')
order by id1,id2;
select ']}';