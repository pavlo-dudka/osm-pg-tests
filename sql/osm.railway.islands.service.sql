set enable_seqscan=false;

DO $$
BEGIN
delete from mainIslandRail where railway_level='crossover';
perform CreateIslandsRail('spur','siding','yard','crossover');
END$$;

select '{';
select '"type": "FeatureCollection",';
select '"errorDescr": "Floating railway island",';
select '"features": [';

with tab as (select max(railway_level) railway_level, count(*) as NumberOfRoads, string_agg('w'||id, ','  order by id) objects, array_agg(id order by id) arr 
             from mainIslandRail
             where ind > 1 and railway_level in ('spur','siding','yard','crossover')
             group by ind)
select '{"type":"Feature","properties":{"josm":"'||objects||'","level":"'||railway_level||'","NumberOfRoads":"'||NumberOfRoads||'"},'||
       '"geometry":'||(select st_asgeojson(st_collect(linestring),5) from railways where id=any(arr))||'},'
from tab
order by arr[1];

select '{"type":"Feature"}';
select ']}';