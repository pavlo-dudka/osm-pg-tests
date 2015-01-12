drop table streets_sloviansk;
create table streets_sloviansk(name text,osm_name_uk text,osm_name_ru text);
copy streets_sloviansk(name) from 'osm/street_names/sloviansk.txt';

--select distinct substr(name,1,position(' ' in name)-1) from streets_sloviansk;
update streets_sloviansk
set
osm_name_uk=
 case when length(name)-length(replace(name,' ',''))=6 then array_to_string((regexp_split_to_array(name,' '))[5:7],' ')
      when length(name)-length(replace(name,' ',''))=4 then array_to_string((regexp_split_to_array(name,' '))[4:5],' ')
      when length(name)-length(replace(name,' ',''))=2 then (regexp_split_to_array(name,' '))[3]
 end || ' ' || (regexp_split_to_array(name,' '))[1],
osm_name_ru=
 case when length(name)-length(replace(name,' ',''))=6 then array_to_string((regexp_split_to_array(name,' '))[2:4],' ')
      when length(name)-length(replace(name,' ',''))=4 then array_to_string((regexp_split_to_array(name,' '))[2:3],' ')
      when length(name)-length(replace(name,' ',''))=2 then (regexp_split_to_array(name,' '))[2]
 end || ' ' ||
 case when (regexp_split_to_array(name,' '))[1] = 'хутір' then 'хутор'
      when (regexp_split_to_array(name,' '))[1] = 'площа' then 'площадь'
      when (regexp_split_to_array(name,' '))[1] = 'станція' then 'станция'
      when (regexp_split_to_array(name,' '))[1] = 'в’їзд' then 'въезд'
      when (regexp_split_to_array(name,' '))[1] = 'вулиця' then 'улица'
      when (regexp_split_to_array(name,' '))[1] = 'провулок' then 'переулок'
 else (regexp_split_to_array(name,' '))[1] end;


with t as (
select w.id,wtn.v name_uk,wtr.v name_ru
from relations r
inner join relation_tags rt on rt.relation_id=r.id and rt.k='name' and rt.v='Слов’янськ'
inner join ways w on st_contains(r.linestring,st_centroid(w.linestring))
inner join way_tags wtn on wtn.way_id=w.id and wtn.k='name'
left  join way_tags wtr on wtr.way_id=w.id and wtr.k='name:ru'
inner join way_tags wth on wth.way_id=w.id and wth.k='highway')
select coalesce(sd.osm_name_uk,''),t.name_uk,string_agg(t.id::text,',' order by t.id),coalesce(sd.osm_name_ru,''),t.name_ru
from streets_sloviansk sd
full join t on lower(sd.osm_name_uk)=lower(t.name_uk) and lower(coalesce(sd.osm_name_ru,t.name_ru,''))=lower(coalesce(t.name_ru,''))
where (t.id is null or sd.osm_name_uk is null)
group by sd.osm_name_uk,sd.osm_name_ru,t.name_uk,t.name_ru
order by coalesce(sd.osm_name_uk,t.name_uk),3;