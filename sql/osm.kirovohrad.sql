drop table streets_kirovohrad;
create table streets_kirovohrad(osm_name_uk text,osm_old_name_uk text);
copy streets_kirovohrad(osm_name_uk) from 'osm/street_names/kirovohrad.csv' csv quote '"';

drop table if exists streets_kirovohrad_upd;
create table streets_kirovohrad_upd(osm_name_old text,osm_name_new text);
copy streets_kirovohrad_upd(osm_name_old,osm_name_new) from 'osm/street_renamings/3510100000.csv' csv;
                         
update streets_kirovohrad s
set osm_old_name_uk=s.osm_name_uk,
osm_name_uk=su.osm_name_new
from streets_kirovohrad_upd su
where su.osm_name_old=s.osm_name_uk;

insert into streets_kirovohrad(osm_name_uk, osm_old_name_uk)
select osm_name_new,osm_name_old from streets_kirovohrad_upd su
where not exists(select * from streets_kirovohrad s where s.osm_name_uk=su.osm_name_new);

with t as (
select w.id,wtn.v name_uk,wtou.v old_name_uk
from relations r
inner join relation_tags rt on rt.relation_id=r.id and rt.k='name' and rt.v='Кропивницький'
inner join ways w on st_contains(r.linestring,st_centroid(w.linestring))
inner join way_tags wtn on wtn.way_id=w.id and wtn.k='name'
left  join way_tags wtou on wtou.way_id=w.id and wtou.k='old_name'
inner join way_tags wth on wth.way_id=w.id and wth.k='highway')
select coalesce(sd.osm_name_uk,''),t.name_uk,string_agg(t.id::text,',' order by t.id),null,null,null,coalesce(sd.osm_old_name_uk,'')
from streets_kirovohrad sd
full join t on lower(sd.osm_name_uk)=lower(t.name_uk)
           and lower(coalesce(sd.osm_old_name_uk,t.old_name_uk,''))=lower(coalesce(t.old_name_uk,''))
where (t.id is null or sd.osm_name_uk is null)
group by sd.osm_old_name_uk,sd.osm_name_uk,t.name_uk
order by coalesce(sd.osm_name_uk,t.name_uk),3;