drop table streets_kyiv;
create table streets_kyiv(id text, name text, type text, district text, location text, osm_name_uk text);
copy streets_kyiv(id,name,type,district,location) from 'osm/street_names/Kyiv.csv' csv quote '"' delimiter ';';

update streets_kyiv s set name=replace(name,'''','’')
where name like '%''%';
update streets_kyiv set osm_name_uk=name||' '||type;
update streets_kyiv s set osm_name_uk=n.name||' '||replace(osm_name_uk, ' '||n.name, '')
from names n
where s.name like '% '||n.name;
update streets_kyiv s set osm_name_uk=t.title||' '||replace(osm_name_uk, ' '||t.title, '')
from titles t
where s.name like '% '||t.title;
update streets_kyiv s set osm_name_uk=regexp_replace(name, '^.* ', '')||'-а '||replace(name, regexp_replace(name, '^.* ', ''), '')||s.type
where s.name similar to '%[0-9](-__?)?';
update streets_kyiv s set osm_name_uk=regexp_replace(name, '^.* ', '')||'-я '||replace(name, regexp_replace(name, '^.* ', ''), '')||s.type
where s.name similar to '%3(-__?)?';
update streets_kyiv s set osm_name_uk=regexp_replace(name, '^.* ', '')||'-а '||replace(name, regexp_replace(name, '^.* ', ''), '')||s.type
where s.name similar to '%13(-__?)?';
update streets_kyiv s set osm_name_uk=regexp_replace(osm_name_uk, '-.?.?-', '-')
where s.osm_name_uk similar to '[0-9]{1,3}-(__?)-%';
update streets_kyiv s set osm_name_uk=regexp_replace(osm_name_uk,'-[ая]','-й')
where s.osm_name_uk similar to '[0-9]{1,3}-[ая]%провулок';
update streets_kyiv s set osm_name_uk=replace(osm_name_uk,'Лінія ','')
where osm_name_uk like '% Лінія лінія';
update streets_kyiv s set osm_name_uk=regexp_replace(osm_name_uk,'  ',' ')
where osm_name_uk like '%  %';

with t as (
select w.id,wtn.v name_uk
from relations r
inner join relation_tags rt on rt.relation_id=r.id and rt.k='name' and rt.v='Київ'
inner join ways w on st_contains(r.linestring,st_centroid(w.linestring))
inner join way_tags wtn on wtn.way_id=w.id and wtn.k='name'
inner join way_tags wth on wth.way_id=w.id and wth.k='highway' and wth.v not in ('footway','path','cycleway','platform'))
select coalesce(sd.osm_name_uk,''),t.name_uk,string_agg(t.id::text,',' order by t.id),sd.id,sd.district,sd.location
from streets_kyiv sd
full join t on lower(sd.osm_name_uk)=lower(t.name_uk)
where (t.id is null or sd.osm_name_uk is null)
group by sd.osm_name_uk,t.name_uk,sd.id,sd.district,sd.location
order by coalesce(sd.osm_name_uk,t.name_uk),3;