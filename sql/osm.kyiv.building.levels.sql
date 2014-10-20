drop table if exists kyiv_building_levels;
create table kyiv_building_levels(street text, housenumber text, levels int);
copy kyiv_building_levels from 'osm/kyiv.building.levels.txt' using delimiters '|';


select '{';
select '"type": "FeatureCollection",';
select '"errorDescr": "Highways not found",';
select '"features": [';

with kyiv as (select * from regions where name='Київ'),
buildings as (
select w.id, coalesce(wta.v, rt.v) street, wth.v housenumber, wtl.v levels, st_pointn(w.linestring, 2) geom
from kyiv 
  inner join ways w on st_contains(kyiv.linestring, w.linestring)
  left  join way_tags wtl on wtl.way_id=w.id and wtl.k='building:levels'
  inner join way_tags wth on wth.way_id=w.id and wth.k='addr:housenumber'
  left  join way_tags wta on wta.way_id=w.id and wta.k='addr:street'
  left  join relation_members rm on rm.member_id=w.id and rm.member_type='W' and rm.member_role in ('house', 'address')
  left  join relation_tags rt on rt.relation_id=rm.relation_id and rt.k='name'
where coalesce(wta.v, rt.v) is not null
)
select '{"type":"Feature","id":"'||b.id||'","properties":{"josm":"w'||b.id||'","address":"'||b.street||', '||b.housenumber||'","levels":"'||b.levels||' or '||kbl.levels||'?"},"geometry":'||st_asgeojson(b.geom,5)||'},' 
from buildings b
 inner join kyiv_building_levels kbl on b.street=kbl.street and (b.housenumber=kbl.housenumber or replace(b.housenumber, ' к', '-')=kbl.housenumber) and b.levels<>kbl.levels::text
order by b.street, b.housenumber, b.id;

select '{"type":"Feature"}';
select ']}';