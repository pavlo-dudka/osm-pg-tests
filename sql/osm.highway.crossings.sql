drop table if exists intsc;
create unlogged table intsc tablespace osmspace as
select t1.id as id1,t2.id as id2,
       case when nodes_geom is null then ST_Intersection(t1.linestring,t2.linestring)
       else                st_difference(ST_Intersection(t1.linestring,t2.linestring), nodes_geom)
       end as diff
from highways t1 inner join highways t2 on ST_Intersects(t1.linestring,t2.linestring) = 't' and t1.id<t2.id and t1.layer=t2.layer
left join cross_way_nodes on way_id_1=t1.id and way_id_2=t2.id
where not(t1.highway_level in ('runway','taxiway') and st_isclosed(t1.linestring))
  and not(t2.highway_level in ('runway','taxiway') and st_isclosed(t2.linestring));

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
