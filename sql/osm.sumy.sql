drop table streets_sumy;
create table streets_sumy(name text, osm_name_uk text);
copy streets_sumy(name) from 'osm/street_names/sumy.txt';

update streets_sumy
set osm_name_uk=
case when name like 'вул. %' then substr(name,1+position(' ' in name))||' вулиця'
     when name like 'пл. %' then substr(name,1+position(' ' in name))||' площа'
     when name like 'пров. %' then substr(name,1+position(' ' in name))||' провулок'
     when name like 'проїзд %' then substr(name,1+position(' ' in name))||' проїзд'
     when name like 'проспект %' then substr(name,1+position(' ' in name))||' проспект'
     when name like 'майдан %' then substr(name,1+position(' ' in name))||' майдан'
     when name like 'тупик %' then substr(name,1+position(' ' in name))||' тупик'
else name end;


with t as (
select w.id,wtn.v name_uk
from relations r
inner join relation_tags rt on rt.relation_id=r.id and rt.k='name' and rt.v='Суми'
inner join ways w on st_contains(r.linestring,st_centroid(w.linestring))
inner join way_tags wtn on wtn.way_id=w.id and wtn.k='name'
inner join way_tags wth on wth.way_id=w.id and wth.k='highway')
select coalesce(sd.osm_name_uk,''),t.name_uk,string_agg(t.id::text,',' order by t.id)
from streets_sumy sd
full join t on lower(sd.osm_name_uk)=lower(t.name_uk)
where (t.id is null or sd.osm_name_uk is null)
group by sd.osm_name_uk,t.name_uk
order by coalesce(sd.osm_name_uk,t.name_uk);