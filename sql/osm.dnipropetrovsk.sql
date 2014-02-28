truncate table streets_dnipropetrovsk;
copy streets_dnipropetrovsk(id,ref,uk_type,uk,ru,district) from 'osm/street_names/dnipropetrovsk.csv' csv quote '"';
update streets_dnipropetrovsk set ru=null where length(ru)<=1;
update streets_dnipropetrovsk set ru_type=(case when uk_type='вулиця' then 'улица'
						when uk_type='провулок' then 'переулок'
						when uk_type='міст' then 'мост'
						when uk_type='узвіз' then 'спуск'
						when uk_type='площа' then 'площадь'
						when uk_type='шосе' then 'шоссе'
						when uk_type='проїзд' then 'проезд'
						when uk_type='станція' then 'станция'
					   else uk_type end);
update streets_dnipropetrovsk set osm_name_uk=uk||' '||uk_type,osm_name_ru=ru||' '||ru_type;

with t as (
select w.id,wtn.v name_uk,wtr.v name_ru
from relations r
inner join relation_tags rt on rt.relation_id=r.id and rt.k='name' and rt.v='Дніпропетровськ'
inner join ways w on st_contains(r.linestring,st_centroid(w.linestring))
inner join way_tags wtn on wtn.way_id=w.id and wtn.k='name'
left  join way_tags wtr on wtr.way_id=w.id and wtr.k='name:ru'
inner join way_tags wth on wth.way_id=w.id and wth.k='highway')
select coalesce(sd.osm_name_uk,''),t.name_uk,string_agg(t.id::text,',' order by t.id),sd.district,coalesce(sd.osm_name_ru,''),t.name_ru
from streets_dnipropetrovsk sd
full join t on lower(sd.osm_name_uk)=lower(t.name_uk) and lower(coalesce(sd.osm_name_ru,t.name_ru,''))=lower(coalesce(t.name_ru,''))
where (t.id is null or sd.osm_name_uk is null)
group by sd.osm_name_uk,sd.osm_name_ru,t.name_uk,t.name_ru,sd.district
order by coalesce(sd.osm_name_uk,t.name_uk),district;