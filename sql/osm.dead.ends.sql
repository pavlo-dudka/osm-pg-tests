select '{';
select '"type": "FeatureCollection",';
select '"errorDescr": "Dead node",';
select '"features": [';

select '{"type":"Feature","id":"'||b.id||'","properties":{"josm":"n'||b.id||',w'||h.id||'","region":"'||r.name||'"},"geometry":'||st_asgeojson(b.geom,5)||'},'
from end_nodes b
  inner join highways h on b.way_id=h.id and highway_level in ('trunk','primary','secondary')
  inner join regions r on _st_containsproperly(r.linestring,b.geom)
where b.id not in (2397056225,659524007,314440025,720719749,2790415616,275439745,4235387646,4235387646,4358930492,1020606081,2284836734,4919525305,5151741343,5828601251,6252123679)
order by b.id;

select '{"type":"Feature","id":"'||b.id||'","properties":{"josm":"n'||b.id||',w'||h.id||'","region":"'||r.name||'"},"geometry":'||st_asgeojson(b.geom,5)||'},'
from end_nodes b
  inner join highways h on b.way_id=h.id and highway_level not in ('service','construction','track','footway','steps')
  inner join way_tags wt on wt.way_id=h.id and wt.k='oneway' and wt.v<>'no'
  inner join regions r on _st_containsproperly(r.linestring,b.geom)
where b.id not in (4235387646,4919525305)
order by b.id;

select '{"type":"Feature"}';
select ']}';
