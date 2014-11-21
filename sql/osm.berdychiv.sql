drop table streets_berdychiv;
create table streets_berdychiv(type text,name_uk text,osm_name_uk text);
copy streets_berdychiv(name_uk,type) from 'osm/street_names/berdychiv.csv' csv;

update streets_berdychiv set type='вулиця' where type='вул.';
update streets_berdychiv set type='провулок' where type='пров.';
update streets_berdychiv set osm_name_uk=name_uk||' '||lower(type);

with t as (
select w.id,wtn.v name_uk
from relations r
inner join relation_tags rt on rt.relation_id=r.id and rt.k='name' and rt.v='Бердичів'
inner join ways w on st_contains(r.linestring,st_centroid(w.linestring))
inner join way_tags wtn on wtn.way_id=w.id and wtn.k='name'
inner join way_tags wth on wth.way_id=w.id and wth.k='highway')
select coalesce(sd.osm_name_uk,''),t.name_uk,string_agg(t.id::text,',' order by t.id)
from streets_berdychiv sd
full join t on lower(sd.osm_name_uk)=lower(t.name_uk)
where (t.id is null or sd.osm_name_uk is null)
group by sd.osm_name_uk,t.name_uk
order by coalesce(sd.osm_name_uk,t.name_uk);