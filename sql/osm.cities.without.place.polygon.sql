--select n.id,ntn.v,ntl.v,r.name
select '{';
select '"type": "FeatureCollection",';
select '"errorDescr": "Border not found",';
select '"features": [';
select '{"type":"Feature","id":"'||n.id||'","properties":{"josm":"n'||n.id||'","name":"'||coalesce(replace(ntn.v,'"','\"'),'')||'","population":"'||coalesce(ntl.v,'')||'","region":"'||r.name||'","koatuu":"'||coalesce(ntk.v,'')||'"},"geometry":'||st_asgeojson(n.geom,5)||'},'
from nodes n
inner join node_tags ntp on ntp.node_id=n.id and ntp.k='place' and ntp.v in ('city','town')
left join node_tags ntl on ntl.node_id=n.id and ntl.k='population'
left join node_tags ntk on ntk.node_id=n.id and ntk.k='koatuu'
inner join regions r on st_contains(r.linestring, n.geom)
left join node_tags ntn on ntn.node_id=n.id and ntn.k=(case when r.relation_id in (72639,1574364) then 'name:uk' else 'name' end)
where not exists(select * 
                 from relations p  
                    inner join relation_tags ptn on ptn.relation_id=p.id and ptn.k=ntn.k and ptn.v=ntn.v
                    inner join relation_tags ptp on ptp.relation_id=p.id and ptp.k=ntp.k and ptp.v=ntp.v
                 where _st_contains(p.linestring, n.geom))
  and not exists(select * 
                 from ways p 
                    inner join way_tags ptn on ptn.way_id=p.id and ptn.k=ntn.k and ptn.v=ntn.v
                    inner join way_tags ptp on ptp.way_id=p.id and ptp.k=ntp.k and ptp.v=ntp.v
                 where st_isclosed(p.linestring) and _st_contains(st_makepolygon(p.linestring), n.geom))
order by length(ntl.v) desc,ntl.v desc;

select '{"type":"Feature"}';
select ']}';