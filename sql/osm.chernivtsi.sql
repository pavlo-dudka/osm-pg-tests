/*update streets_chernivtsi sc0 set osm_name=(
with pr as (select unnest(array['Митрополита','генерала','маршала','академіка','гетьмана','фельдмаршала','старшого лейтенанта','адмірала','полковника']) as prefix)
select --id,
trim(
(case when sc.prefix is null then '' else sc.prefix||' ' end)||
(case when pr.prefix is null then '' else initcap(pr.prefix)||' ' end)||
trim(leading ' ' from (trim(replace(replace(replace(replace(full_name,case when sc.prefix<>'' then sc.prefix||' ' else '' end,'')||' ',street_type_short||' ',''),sc.short_name||' ',''),case when pr.prefix is null then '' else pr.prefix end,''))||' '))
||short_name||' '||lower(street_type_desc)
) as osm_name
from streets_chernivtsi sc
left join pr on full_name like '% '||pr.prefix||'%'
where sc.id=sc0.id
);*/

with t as (
select w.id,wtn.v
from relations r
inner join relation_tags rt on rt.relation_id=r.id and rt.k='name' and rt.v='Чернівці'
inner join ways w on st_contains(r.linestring,st_centroid(w.linestring))
inner join way_tags wtn on wtn.way_id=w.id and wtn.k='name'
inner join way_tags wth on wth.way_id=w.id and wth.k='highway')
select coalesce(sd.osm_name,'		'),t.v,string_agg(t.id::text,',' order by t.id),sd.location
from streets_chernivtsi sd
full join t on lower(t.v)=lower(sd.osm_name)
where (t.v is null or sd.osm_name is null)
group by sd.osm_name,t.v,sd.location
order by coalesce(sd.osm_name,t.v);