drop table streets_kremenchuk;
create table streets_kremenchuk(id text, name_uk text, osm_name_uk text, location text);
copy streets_kremenchuk(id, name_uk, location) from 'osm/street_names/kremenchuk.csv' delimiter '|' csv quote '"';

update streets_kremenchuk set name_uk='вулиця Гетьманська' where name_uk='Гетьманська';
update streets_kremenchuk set osm_name_uk=trim(substr(replace(name_uk,'''','’'),position(' ' in name_uk)+1))||' '||type_f
from way_type where lower(name_uk) like type_f||' %';
update streets_kremenchuk set osm_name_uk=substr(osm_name_uk,1,3)||'-й квартал' where osm_name_uk like '% квартал';
update streets_kremenchuk set osm_name_uk='1905-го року вулиця' where osm_name_uk='1905 року вулиця';
update streets_kremenchuk set osm_name_uk='29-го Вересня вулиця' where osm_name_uk='29 Вересня вулиця';

with t as (
select w.id,wtn.v name_uk
from relations r
inner join relation_tags rt on rt.relation_id=r.id and rt.k='name' and rt.v='Кременчук'
inner join ways w on st_contains(r.linestring,st_centroid(w.linestring))
inner join way_tags wtn on wtn.way_id=w.id and wtn.k='name'
inner join way_tags wth on wth.way_id=w.id and wth.k='highway')
select coalesce(sd.osm_name_uk,''),t.name_uk,string_agg(t.id::text,',' order by t.id),sd.location
from streets_kremenchuk sd
full join t on lower(sd.osm_name_uk)=lower(t.name_uk)
where (t.id is null or sd.osm_name_uk is null)
group by sd.osm_name_uk,t.name_uk,sd.location
order by coalesce(sd.osm_name_uk,t.name_uk);