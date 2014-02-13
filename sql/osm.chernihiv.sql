with t as (
select w.id,wtn.v 
from relations r
inner join relation_tags rt on rt.relation_id=r.id and rt.k='name' and rt.v='Чернігів'
inner join ways w on st_contains(r.linestring,w.linestring)
inner join way_tags wtn on wtn.way_id=w.id and wtn.k='name'
inner join way_tags wth on wth.way_id=w.id and wth.k='highway')
select coalesce(trim(prefix||' '||name||' '||type),'		'),t.v,string_agg(t.id::text,',' order by t.id)
from streets_chernihiv sd
full join t on lower(t.v)=trim(lower(prefix||' '||name||' '||type))
where (t.v is null or sd.name is null)
group by sd.name,sd.type,t.v,sd.prefix
order by coalesce(trim(prefix||' '||name),t.v),sd.type;