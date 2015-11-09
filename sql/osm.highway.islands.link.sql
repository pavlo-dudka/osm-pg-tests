set enable_seqscan=false;

select '{';
select '"type": "FeatureCollection",';
select '"errorDescr": "Floating link island",';
select '"features": [';

--trunk
truncate table mainisland;
insert into mainisland(id)
select id from highways where highway_level='trunk';

DO $$
BEGIN
perform CreateIslands('trunk_link');
end$$;

with tab as (select min(highway_level) highway_level, count(*) as NumberOfRoads, string_agg('w'||id, ','  order by id) objects, array_agg(id order by id) arr 
             from mainIsland
             where ind > 1
             group by ind)
select '{"type":"Feature","properties":{"josm":"'||objects||'","level":"'||highway_level||'","NumberOfRoads":"'||NumberOfRoads||'"},'||
       '"geometry":'||(select st_asgeojson(st_collect(linestring),5) from highways where id=any(arr))||'},'
from tab
order by arr[1];


--primary
truncate table mainisland;
insert into mainisland(id)
select id from highways where highway_level='primary';

DO $$
BEGIN
perform CreateIslands('primary_link');
end$$;

with tab as (select min(highway_level) highway_level, count(*) as NumberOfRoads, string_agg('w'||id, ','  order by id) objects, array_agg(id order by id) arr 
             from mainIsland
             where ind > 1
             group by ind)
select '{"type":"Feature","properties":{"josm":"'||objects||'","level":"'||highway_level||'","NumberOfRoads":"'||NumberOfRoads||'"},'||
       '"geometry":'||(select st_asgeojson(st_collect(linestring),5) from highways where id=any(arr))||'},'
from tab
order by arr[1];


--secondary
truncate table mainisland;
insert into mainisland(id)
select id from highways where highway_level='secondary';

DO $$
BEGIN
perform CreateIslands('secondary_link');
end$$;

with tab as (select min(highway_level) highway_level, count(*) as NumberOfRoads, string_agg('w'||id, ','  order by id) objects, array_agg(id order by id) arr 
             from mainIsland
             where ind > 1
             group by ind)
select '{"type":"Feature","properties":{"josm":"'||objects||'","level":"'||highway_level||'","NumberOfRoads":"'||NumberOfRoads||'"},'||
       '"geometry":'||(select st_asgeojson(st_collect(linestring),5) from highways where id=any(arr))||'},'
from tab
order by arr[1];


--tertiary
truncate table mainisland;
insert into mainisland(id)
select id from highways where highway_level='tertiary';

DO $$
BEGIN
perform CreateIslands('tertiary_link');
end$$;

with tab as (select min(highway_level) highway_level, count(*) as NumberOfRoads, string_agg('w'||id, ','  order by id) objects, array_agg(id order by id) arr 
             from mainIsland
             where ind > 1
             group by ind)
select '{"type":"Feature","properties":{"josm":"'||objects||'","level":"'||highway_level||'","NumberOfRoads":"'||NumberOfRoads||'"},'||
       '"geometry":'||(select st_asgeojson(st_collect(linestring),5) from highways where id=any(arr))||'},'
from tab
order by arr[1];


select '{"type":"Feature"}';
select ']}';