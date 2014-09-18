select 'building-node in a way:';
select wn.node_id,wn.way_id,string_agg(wt.k||':'||wt.v,';  ' order by wt.k)
from way_nodes wn
inner join node_tags nt on nt.node_id=wn.node_id
left join way_tags wt on wt.way_id=wn.way_id
left join way_tags wti on wti.way_id=wn.way_id and wti.k='addr:interpolation'
where nt.k='building' and nt.v<>'entrance' and wti.k is null
group by wn.node_id,wn.way_id
order by wn.node_id,wn.way_id;

/*select '';
select 'Building on Square:';
select 'r'||a.id||',w'||b.id
from relations a
inner join relation_tags wta on wta.relation_id=a.id and wta.k like 'area%' and wta.v<>'disputed'
inner join relation_tags wth on wth.relation_id=wta.relation_id and wth.k like '%highway%'
left  join ways b on st_isvalid(a.linestring) and st_isvalid(b.linestring) and _st_contains(a.linestring, b.linestring) and a.id<>b.id 
left  join way_tags wtb on wtb.way_id=b.id and wtb.k = 'building'
where b.id is not null;*/

select '';
select 'Redundant space-symbols:';
select * from node_tags where trim(v)<>v order by 1,2;
select * from way_tags where trim(v)<>v order by 1,2;

select '';
select 'No suffix:';
select v,string_agg(distinct way_id::text,',' order by way_id::text) 
from way_tags 
where v similar to '%[1-9][0-9]*((-_)?[аяй])? %|% [0-9]*-(а|я) %|3-а %' and k in ('name','name:uk','name:ru','addr:street') and v not like '% рок%' and v not like '% лет %' and v not like '% года %' and v not like '% - %' 
and way_id in (select way_id from way_tags where k='highway')
group by v order by 1;