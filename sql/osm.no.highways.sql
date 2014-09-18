select '{';
select '"type": "FeatureCollection",';
select '"errorDescr": "Highways not found",';
select '"features": [';
select '{"type":"Feature","id":"'||n.id||'","properties":{"josm":"n'||n.id||'","name":"'||coalesce(replace(ntn.v,'"','\"'),'')||'","population":"'||coalesce(ntl.v,'')||'","region":"'||r.name||'","koatuu":"'||coalesce(ntk.v,'')||'"},"geometry":'||st_asgeojson(n.geom,5)||'},'
from node_tags nt
  inner join nodes n on n.id=nt.node_id  
  left join node_tags ntl on id=ntl.node_id and ntl.k='population' and ntl.v similar to '[0-9]*'
  left join node_tags ntk on ntk.node_id=n.id and ntk.k='koatuu'
  inner join regions r on st_contains(r.linestring, n.geom)
  left join node_tags ntn on ntn.node_id=n.id and ntn.k=(case when r.relation_id in (72639,1574364) then 'name:uk' else 'name' end)
where nt.k='place' and nt.v in ('city','town','village','hamlet') and
n.id not in (337696888,337689331,1224164975,371949683,2778969193,1464223496) and
coalesce(ntl.v::int, 999)>20 and
not exists(select 1 from highways w where st_dwithin(n.geom,w.linestring,0.1) and st_distance_sphere(n.geom,w.linestring) < 500) and
not exists(select 1 from node_tags where node_id=n.id and k='abandoned')
order by n.id;

select '{"type":"Feature"}';
select ']}';