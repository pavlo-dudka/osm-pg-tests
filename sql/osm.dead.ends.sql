select '{';
select '"type": "FeatureCollection",';
select '"errorDescr": "Dead-end of high level road",';
select '"features": [';
select '{"type":"Feature","id":"'||b.id||'","properties":{"josm":"n'||b.id||',w'||h.id||'"},"geometry":'||st_asgeojson(b.geom,5)||'},'
from end_nodes b
  inner join highways h on b.way_id=h.id and highway_level in ('trunk','primary','secondary')
  inner join regions r on _st_contains(r.linestring,b.geom)
where b.id not in (2397056225)
order by b.id;

select '{"type":"Feature"}';
select ']}';