set enable_seqscan=false;

DO $$
BEGIN
perform CreateIslands('motorway','motorway_link');
perform CreateIslands('trunk','trunk_link');
perform CreateIslands('primary','primary_link');
perform CreateIslands('secondary','secondary_link');
perform CreateIslands('tertiary','tertiary_link');
END$$;

select '{';
select '"type": "FeatureCollection",';
select '"errorDescr": "Floating island",';
select '"features": [';

with tab as (select min(highway_level) highway_level, count(*) as NumberOfRoads, string_agg('w'||id, ','  order by id) objects, array_agg(id order by id) arr 
             from mainIsland
             where ind > 1
             group by substr(highway_level,1,5),ind)
select '{"type":"Feature","properties":{"josm":"'||objects||'","level":"'||highway_level||'","NumberOfRoads":"'||NumberOfRoads||'"},'||
       '"geometry":'||(select st_asgeojson(st_collect(linestring),5) from highways where id=any(arr))||'},'
from tab
order by (case when highway_level like 'motorway%' then 1 
               when highway_level like 'trunk%' then 2
               when highway_level like 'primary%' then 3
               when highway_level like 'secondary%' then 4
               when highway_level like 'tertiary%' then 5 end), arr[1];

select '{"type":"Feature"}';
select ']}';