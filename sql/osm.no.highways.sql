select '{';
select '"type": "FeatureCollection",';
select '"errorDescr": "Highways not found",';
select '"features": [';
select '{"type":"Feature","id":"'||n.id||'","properties":{"josm":"n'||n.id||'","name":"'||coalesce(replace(ntn.v,'"','\"'),'')||'"},"geometry":'||st_asgeojson(n.geom,5)||'},'
from node_tags nt
  inner join nodes n on n.id=nt.node_id  
  left join node_tags ntn on id=ntn.node_id and ntn.k='name'
  left join node_tags nt2 on id=nt2.node_id and nt2.k='population' and nt2.v similar to '[0-9]*'
where nt.k='place' and nt.v in ('city','town','village','hamlet') and
n.id not in (337696888,337689331,1224164975,371949683,2778969193) and
coalesce(nt2.v::int, 999)>20 and
not exists(select 1 from highways w where st_dwithin(n.geom,w.linestring,0.1) and st_distance_sphere(n.geom,w.linestring) < 500)
order by n.id;

select '{"type":"Feature"}';
select ']}';