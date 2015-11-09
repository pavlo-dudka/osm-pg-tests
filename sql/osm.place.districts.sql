select '{';
select '"type": "FeatureCollection",';
select '"errorDescr": "Invalid district border or place location",';
select '"features": [';

select '{"type":"Feature","id":"'||n.id||'","properties":{"josm":"n'||n.id||',r'||r.relation_id||',r'||r2.relation_id||'","cur_district":"'||r.name||'","exp_district":"'||r2.name||'","name":"'||coalesce(replace(ntn.v,'"','\"'),'')||'","region":"'||reg.name||'","koatuu":"'||coalesce(ntk.v,'')||'"},"geometry":'||st_asgeojson(n.geom,5)||'},'
from node_tags ntp
inner join nodes n on n.id=ntp.node_id
inner join districts r on st_contains(r.linestring, n.geom)
inner join node_tags ntn on ntn.node_id=n.id and ntn.k='name'
inner join node_tags ntk on ntk.node_id=n.id and ntk.k='koatuu'
left  join districts r2 on r2.koatuu=substr(ntk.v,1,5)||'00000'
left  join regions reg on st_contains(reg.linestring,n.geom)
where ntp.k='place' and ntp.v in ('city','town','village','hamlet')
  and substr(ntk.v,1,5)<>substr(r.koatuu,1,5)
order by ntk.v;

select '{"type":"Feature"}';
select ']}';