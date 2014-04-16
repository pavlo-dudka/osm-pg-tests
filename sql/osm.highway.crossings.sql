drop table if exists cross_way_nodes;
create table cross_way_nodes as
select wn.way_id,wn.node_id,geom as node_geom from way_nodes wn
inner join nodes on node_id=id
where way_id in (select id from highways) and node_id in (select node_id from way_nodes where way_id in (select id from highways) group by node_id having count(distinct way_id)>1);
create index idx_cross_way_nodes_way_id on cross_way_nodes(way_id,node_id,node_geom);

drop table if exists intsc;
create table intsc as
select t1.id as id1,t2.id as id2,
       case when not exists(select 1 from cross_way_nodes where way_id in (t1.id,t2.id) group by node_id having count(distinct way_id)>1) 
            then ST_Intersection(t1.linestring,t2.linestring)
       else
            st_difference(ST_Intersection(t1.linestring,t2.linestring), 
                          (select st_multi(st_collect(node_geom)) from (select node_geom from cross_way_nodes where way_id in (t1.id,t2.id) group by node_id,node_geom having count(distinct way_id)>1) sq)) 
       end as diff
from highways t1, highways t2
where ST_Intersects(t1.linestring,t2.linestring) = 't' and t1.id<t2.id and t1.layer=t2.layer;  

--drop table if exists highways;
drop table if exists cross_way_nodes;

--create GeoJson
select '{';
select '"type": "FeatureCollection",';
select '"errorDescr": "Intersection without common node",';
select '"features": [';
select '{"type":"Feature","properties":{"josm":"w'||id1||',w'||id2||'"},"geometry":'||st_asgeojson((select (st_dumppoints(diff)).geom limit 1),5)||'},'
from intsc
where st_isempty(diff) = 'f'
order by id1,id2;

select '{"type":"Feature"}';
select ']}';