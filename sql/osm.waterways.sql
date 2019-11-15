select '{';
select '"type": "FeatureCollection",';
select '"errorDescr": "Check waterway layer",';
select '"features": [';

select '{"type":"Feature","properties":{"josm":"w'||w.id||'","name":"'||coalesce(wtn.v,'')||'","level":"'||coalesce(wtl.v,'0')||'","length":"'||round((st_length(w.linestring::geography)/10))/100||'"},"geometry":'||st_asgeojson(w.linestring, 5)||'},'
from ways w
  inner join way_tags wt on wt.way_id=w.id and wt.k='waterway' and wt.v not in ('dam','weir')
  left  join way_tags wtl on wtl.way_id=w.id and wtl.k='layer' and wtl.v<>'0'
  left  join way_tags wtn on wtn.way_id=w.id and wtn.k='name'
  left  join way_tags wtt on wtt.way_id=w.id and wtt.k='tunnel' and wtt.v in ('yes','culvert','flooded')
  left  join way_tags wtb on wtb.way_id=w.id and wtb.k='bridge' and wtb.v='aqueduct'
where w.id not in (389441225,389381465,389381464)
  and (wtl.v like '-%' and wtt.k is null or wtl.v not like '-%' and wtb.k is null 
  /*or wtl.k is null and wtt.k is not null*/ or wtl.k is null and wtb.k is not null)
order by st_length(w.linestring::geography) desc;

select '{"type":"Feature"}';
select ']}';