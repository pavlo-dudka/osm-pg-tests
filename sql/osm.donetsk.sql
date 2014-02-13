with t as (
select w.id,wtn.v 
from relations r
inner join relation_tags rt on rt.relation_id=r.id and rt.k='name' and rt.v='Донецьк'
inner join ways w on st_contains(r.linestring,w.linestring)
inner join way_tags wtn on wtn.way_id=w.id and wtn.k='name'
left  join way_tags wtr on wtr.way_id=w.id and wtr.k='name:ru'
inner join way_tags wth on wth.way_id=w.id and wth.k='highway')
select coalesce(sd.uk||' '||sd.uk_type,'		'),t.v,string_agg(t.id::text,',' order by t.id)
from streets_donetsk sd
full join t on lower(t.v)=lower(uk)||' '||uk_type
where (t.v is null or sd.uk is null) --and coalesce(sd.uk||' ',t.v) like '% % %'
group by sd.uk,sd.uk_type,t.v
order by coalesce(sd.uk,t.v),sd.uk_type;