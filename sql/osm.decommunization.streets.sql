select '{';
select '"type": "FeatureCollection",';
select '"errorDescr": "not renamed yet",';
select '"no_markers": "true",';
select '"features": [';

with tab as (
select h.id,h.linestring,wtn.v old_name 
from ways h
inner join way_tags wtn on wtn.way_id=h.id and wtn.k='name'
where exists(select * from way_tags where way_id=id and k='highway')
  and exists(select * from decommunization_names dn where position(dn.name||' ' in wtn.v)>0)
  and not exists(select * from relations r where r.id in (72639/*ARK*/,1574364/*Sevas*/,4473309/*Ordlo*/) and st_contains(r.linestring, h.linestring))
)
select '{"type":"Feature","properties":{"josm":"w'||id||'","old_name":"'||old_name||'"},'||
       '"geometry":'||(select st_asgeojson(linestring,5))||'},'
from tab
order by id;

select '{"type":"Feature"}';
select ']}';