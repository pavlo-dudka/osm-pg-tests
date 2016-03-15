drop table streets_dnipropetrovsk;
create table streets_dnipropetrovsk(id int,ref text,uk_type text,uk text,ru text,district text,ru_type text,osm_name_uk text,osm_name_ru text,osm_old_name_uk text,osm_old_name_ru text);
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
update streets_dnipropetrovsk set district='Амур-Нижньодніпровський' where district='АНД';

drop table if exists streets_dnipropetrovsk_upd;
create table streets_dnipropetrovsk_upd(district text,osm_name_old text,osm_name_new text);
copy streets_dnipropetrovsk_upd(osm_name_old,osm_name_new,district) from 'osm/street_names/dnipropetrovsk_upd.csv' csv;
copy streets_dnipropetrovsk_upd(osm_name_old,osm_name_new,district) from 'osm/street_names/dnipropetrovsk_upd2.csv' csv;
copy streets_dnipropetrovsk_upd(osm_name_old,osm_name_new,district) from 'osm/street_names/dnipropetrovsk_upd3.csv' csv;
update streets_dnipropetrovsk s
set osm_old_name_uk=s.osm_name_uk, osm_old_name_ru=s.osm_name_ru,
osm_name_uk=su.osm_name_new, osm_name_ru=null
from streets_dnipropetrovsk_upd su
where su.osm_name_old=s.osm_name_uk and su.district like '%'||s.district||'%';

update streets_dnipropetrovsk set district='Соборний' where district='Жовтневий';

with t as (
select w.id,wtn.v name_uk,wtr.v name_ru,wtou.v old_name_uk,wtor.v old_name_ru
from relations r
inner join relation_tags rt on rt.relation_id=r.id and rt.k='name' and rt.v='Дніпропетровськ'
inner join ways w on st_contains(r.linestring,st_centroid(w.linestring))
inner join way_tags wtn on wtn.way_id=w.id and wtn.k='name'
left  join way_tags wtr on wtr.way_id=w.id and wtr.k='name:ru'
left  join way_tags wtou on wtou.way_id=w.id and wtou.k='old_name'
left  join way_tags wtor on wtor.way_id=w.id and wtor.k='old_name:ru'
inner join way_tags wth on wth.way_id=w.id and wth.k='highway')
select coalesce(sd.osm_name_uk,''),t.name_uk,string_agg(t.id::text,',' order by t.id),sd.district,coalesce(sd.osm_name_ru,''),t.name_ru,coalesce(sd.osm_old_name_uk,''),coalesce(sd.osm_old_name_ru,'')
from streets_dnipropetrovsk sd
full join t on lower(sd.osm_name_uk)=lower(t.name_uk) 
           and lower(coalesce(sd.osm_name_ru,t.name_ru,''))=lower(coalesce(t.name_ru,''))
           and lower(coalesce(sd.osm_old_name_uk,t.old_name_uk,''))=lower(coalesce(t.old_name_uk,''))
           and lower(coalesce(sd.osm_old_name_ru,t.old_name_ru,''))=lower(coalesce(t.old_name_ru,''))
where (t.id is null or sd.osm_name_uk is null)
group by sd.osm_name_uk,sd.osm_name_ru,t.name_uk,t.name_ru,sd.district,sd.osm_old_name_uk,sd.osm_old_name_ru
order by coalesce(sd.osm_old_name_uk,sd.osm_name_uk,t.name_uk),district;