truncate table streets_dnipropetrovsk;
copy streets_dnipropetrovsk(id,ref,uk_type,uk,ru,district) from 'osm/street_names/dnipropetrovsk.csv' delimiter ',';
update streets_dnipropetrovsk set uk=replace(uk,'''','’');
update streets_dnipropetrovsk set osm_name=uk||' '||uk_type;

with t as (
select w.id,wtn.v
from relations r
inner join relation_tags rt on rt.relation_id=r.id and rt.k='name' and rt.v='Дніпропетровськ'
inner join ways w on st_contains(r.linestring,st_centroid(w.linestring))
inner join way_tags wtn on wtn.way_id=w.id and wtn.k='name'
inner join way_tags wth on wth.way_id=w.id and wth.k='highway')
select coalesce(sd.osm_name,'		'),t.v,string_agg(t.id::text,',' order by t.id),sd.district
from streets_dnipropetrovsk sd
full join t on lower(t.v)=lower(sd.osm_name)
where (t.v is null or sd.osm_name is null)
group by sd.osm_name,t.v,sd.district
order by coalesce(sd.osm_name,t.v);