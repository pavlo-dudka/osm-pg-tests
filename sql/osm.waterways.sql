select '{';
select '"type": "FeatureCollection",';
select '"errorDescr": "Check waterway layer",';
select '"features": [';

select '{"type":"Feature","properties":{"josm":"w'||w.id||'","name":"'||coalesce(wtn.v,'')||'","level":"'||wtl.v||'","length":"'||round((st_length(w.linestring::geography)/10))/100||'"},"geometry":'||st_asgeojson(w.linestring, 5)||'},'
from ways w
  inner join way_tags wt on wt.way_id=w.id
  inner join way_tags wtl on wtl.way_id=w.id
  left  join way_tags wtn on wtn.way_id=w.id and wtn.k='name'
where wt.k='waterway' and wt.v not in ('dam','weir') and wtl.k='layer'
  and w.id not in (select way_id from way_tags where k='tunnel')
  and w.id not in (select way_id from way_tags where k='bridge' and v='aqueduct')
  and wtl.v::int not between 0 and 0
order by st_length(w.linestring::geography) desc
limit 100;

select '{"type":"Feature"}';
select ']}';