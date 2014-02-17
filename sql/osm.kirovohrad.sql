truncate table streets_kirovohrad;
copy streets_kirovohrad(osm_name_uk) from 'osm/street_names/kirovohrad.csv' csv quote '"';

with t as (
select w.id,wtn.v name_uk
from relations r
inner join relation_tags rt on rt.relation_id=r.id and rt.k='name' and rt.v='Кіровоград'
inner join ways w on st_contains(r.linestring,st_centroid(w.linestring))
inner join way_tags wtn on wtn.way_id=w.id and wtn.k='name'
inner join way_tags wth on wth.way_id=w.id and wth.k='highway')
select coalesce(sd.osm_name_uk,''),t.name_uk,string_agg(t.id::text,',' order by t.id)
from streets_kirovohrad sd
full join t on lower(sd.osm_name_uk)=lower(t.name_uk)
where (t.id is null or sd.osm_name_uk is null)
group by sd.osm_name_uk,t.name_uk
order by coalesce(sd.osm_name_uk,t.name_uk);