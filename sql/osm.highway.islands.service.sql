set enable_seqscan=false;

insert into mainisland(id)
select id from highways where highway_level in ('pedestrian','runway','taxiway');

DO $$
BEGIN
perform CreateIslands('service');
END$$;

select '{';
select '"type": "FeatureCollection",';
select '"errorDescr": "Floating island",';
select '"features": [';

with tab as (select highway_level, count(*) as NumberOfRoads, string_agg('w'||id, ','  order by id) objects, array_agg(id order by id) arr 
             from mainIsland 
             where ind > 1 and highway_level in ('service')
             group by highway_level, ind)
select '{"type":"Feature","properties":{"josm":"'||objects||'","level":"'||highway_level||'","NumberOfRoads":"'||NumberOfRoads||'"},'||
       '"geometry":'||(select st_asgeojson(st_collect(linestring),5) from highways where id=any(arr))||'},'
from tab
order by arr[1];

select '{"type":"Feature"}';
select ']}';
