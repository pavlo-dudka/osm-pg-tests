drop table streets_mariupol;
create table streets_mariupol(uk_type text,uk text,ru_type text,ru text,osm_name_uk text,osm_name_ru text);
copy streets_mariupol(ru_type,ru,uk_type,uk) from 'osm/street_names/mariupol.csv' csv quote '"';
update streets_mariupol set osm_name_ru=trim(trim(ru)||' '||coalesce(ru_type,'')), osm_name_uk=trim(trim(uk)||' '||coalesce(uk_type,''));

with t as (
select w.id,wtn.v name_uk,wtr.v name_ru
from relations r
inner join relation_tags rt on rt.relation_id=r.id and rt.k='name' and rt.v='Маріуполь'
inner join ways w on st_contains(r.linestring,st_centroid(w.linestring))
inner join way_tags wtn on wtn.way_id=w.id and wtn.k='name'
left  join way_tags wtr on wtr.way_id=w.id and wtr.k='name:ru'
inner join way_tags wth on wth.way_id=w.id and wth.k='highway')
select coalesce(sd.osm_name_uk,''),t.name_uk,string_agg(t.id::text,',' order by t.id),coalesce(sd.osm_name_ru,''),t.name_ru
from streets_mariupol sd
full join t on lower(sd.osm_name_uk)=lower(t.name_uk) and lower(coalesce(sd.osm_name_ru,t.name_ru,''))=lower(coalesce(t.name_ru,''))
where (t.id is null or sd.osm_name_uk is null)
group by sd.osm_name_uk,sd.osm_name_ru,t.name_uk,t.name_ru
order by coalesce(sd.osm_name_uk,t.name_uk),3;