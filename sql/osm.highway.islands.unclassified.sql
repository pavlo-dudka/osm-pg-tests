set enable_seqscan=false;

DO $$
BEGIN
perform CreateIslands('unclassified','residential','living_street');
END$$;

select '{';
select '"type": "FeatureCollection",';
select '"errorDescr": "Floating island",';
select '"features": [';

with tab as (select max(highway_level) highway_level, count(*) as NumberOfRoads, string_agg('w'||id, ','  order by id) objects, array_agg(id order by id) arr 
             from mainIsland 
             where ind > 1 and highway_level in ('unclassified','residential','living_street')
             group by ind)
select '{"type":"Feature","properties":{"josm":"'||objects||'","level":"'||highway_level||'","NumberOfRoads":"'||NumberOfRoads||'"},'||
       '"geometry":'||(select st_asgeojson(st_collect(linestring),5) from highways where id=any(arr))||'},'
from tab
order by arr[1];

select '{"type":"Feature"}';
select ']}';