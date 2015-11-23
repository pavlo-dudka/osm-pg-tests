drop table streets_kramatorsk;
create table streets_kramatorsk(uk_type text,uk text,ru text,district text,ru_type text,osm_name_uk text,osm_name_ru text);
copy streets_kramatorsk(ru,uk,ru_type,district) from 'osm/street_names/kramatorsk.csv' csv;
update streets_kramatorsk set ru_type=(case when ru_type='ул.' then 'улица'
					    when ru_type='пер.' then 'переулок'
					    when ru_type='пл.' then 'площадь'
					    when ru_type='б-р' then 'бульвар'
					    when ru_type='пр-т' then 'проспект' end),
			      uk_type=(case when ru_type='ул.' then 'вулиця'
					    when ru_type='пер.' then 'провулок'
					    when ru_type='пл.' then 'площа'
					    when ru_type='б-р' then 'бульвар'
					    when ru_type='пр-т' then 'проспект' end);

update streets_kramatorsk set osm_name_uk=uk||' '||uk_type,osm_name_ru=ru||' '||ru_type;

with t as (
select w.id,coalesce(wtu.v,wtn.v) name_uk,replace(coalesce(wtr.v,wtn.v),'ё','е') name_ru
from relations r
inner join relation_tags rt on rt.relation_id=r.id and rt.k='name' and rt.v='Краматорська міська рада'
inner join ways w on st_contains(r.linestring,st_centroid(w.linestring))
inner join way_tags wtn on wtn.way_id=w.id and wtn.k='name'
left  join way_tags wtu on wtu.way_id=w.id and wtu.k='name:uk'
left  join way_tags wtr on wtr.way_id=w.id and wtr.k='name:ru'
inner join way_tags wth on wth.way_id=w.id and wth.k='highway')
select coalesce(sd.osm_name_uk,''),t.name_uk,string_agg(t.id::text,',' order by t.id),sd.district,coalesce(sd.osm_name_ru,''),t.name_ru
from streets_kramatorsk sd
full join t on lower(sd.osm_name_uk)=lower(t.name_uk) and lower(coalesce(sd.osm_name_ru,t.name_ru,''))=lower(coalesce(t.name_ru,''))
where (t.id is null or sd.osm_name_uk is null)
group by sd.osm_name_uk,sd.osm_name_ru,t.name_uk,t.name_ru,sd.district
order by coalesce(sd.osm_name_uk,t.name_uk),district;