--select n.id from node_tags 
--inner join nodes n on n.id=node_id and k='place'
--where not exists(select * from relations r,relation_tags rt where r.id=relation_id and rt.k='admin_level' and rt.v='6' and st_contains(linestring,geom)='t');

select 'No admin_centre:';
select relation_id from relation_tags rt where k='admin_level' and v in ('4','6') 
and not exists(select * from relation_members rm where rm.relation_id=rt.relation_id and member_role='admin_centre') 
and not exists(select * from relation_tags rt2 where rt2.relation_id=rt.relation_id and rt2.v='city_district')
order by 1;

select '';
select 'name <> name:uk or invalid symbols in name:';
select node_id,max(v),min(v) from node_tags where k in ('name','name:uk') and node_id in (select node_id from node_tags where k='place') group by node_id having max(v)<>min(v) or min(v) not similar to '[А-Яа-яіїєІЇЄ''’ -]*' order by node_id;

select '';
select 'building-node in a way:';
select wn.node_id,wn.way_id,string_agg(wt.k||':'||wt.v,';  ' order by wt.k)
from way_nodes wn
inner join node_tags nt on nt.node_id=wn.node_id
left join way_tags wt on wt.way_id=wn.way_id
left join way_tags wti on wti.way_id=wn.way_id and wti.k='addr:interpolation'
where nt.k='building' and nt.v<>'entrance' and wti.k is null
group by wn.node_id,wn.way_id
order by wn.node_id,wn.way_id;

/*select way_id,string_agg(k||'='||v,',' order by k) from way_tags where k in ('name','name:uk','name:ru') group by way_id having count(distinct v)=3
and string_agg(k||'='||v,',') not in (
'name=Россия — Україна,name:ru=Россия — Украина,name:uk=Росія — Україна',
'name=Ukraine — Belarus,name:ru=Украина — Белоруссия,name:uk=Україна — Білорусь',
'name=Заходні Буг / Bug,name:ru=Западный Буг,name:uk=Західний Буг',
'name=Nistru / Дністер,name:ru=Днестр,name:uk=Дністер'
)
order by 1;*/

select '';
select 'Redundant space-symbols:';
select * from node_tags where trim(v)<>v order by node_id;
select * from way_tags where trim(v)<>v order by way_id;

select '';
select 'Invalid member type:';
select * 
from relation_tags rt
inner join relation_members rm on rm.relation_id=rt.relation_id and rm.member_type<>'W' and rm.member_role not in ('admin_centre','label','subarea')
where rt.k='type' and rt.v in ('boundary','multipolygon');

select '';
select 'Double boundaries:';
select count(*),n.id,min(r2.id),max(r2.id),min(w2.id),max(w2.id) 
from 
nodes n
inner join node_tags nt on nt.node_id=n.id and nt.k='place'
left join (relations inner join relation_tags rt2 on rt2.relation_id=id and rt2.k='place' and rt2.v<>'city_district') r2 on st_contains(r2.linestring,n.geom)
left join (ways inner join way_tags wt2 on wt2.way_id=id and wt2.k='place') w2 on st_contains(w2.linestring,n.geom)
group by n.id
having count(*)>1 or min(r2.id) is not null and min(w2.id) is not null;

select '';
select 'No suffix:';
select v,string_agg(distinct way_id::text,',' order by way_id::text) 
from way_tags 
where v similar to '%[1-9][0-9]*(-_(а|я))? %|% [0-9]*-(а|я) %|3-а %' and k in ('name','name:uk','name:ru-','addr:street') and v not like '% рок%' and v not like '% лет %' and v not like '% года %' and v not like '% - %' 
and way_id in (select way_id from way_tags where k='highway')
group by v order by 1;