with 
a as (
	select rt.relation_id,wn.way_id,wn.node_id,wn.sequence_id
	from relation_tags rt
	inner join relation_members rm on rm.relation_id=rt.relation_id and rm.member_type='W'
	inner join way_nodes wn on wn.way_id=rm.member_id
	where k='route' and v in ('bus','trolleybus','share_taxi','tram') and rm.member_role not like 'platform%'),
b as (
	select max(sequence_id) as max_sequence_id,relation_id,way_id from a group by relation_id,way_id
),
c as (
	select  b.relation_id,a.way_id,a.node_id
	from b 
	inner join a on a.relation_id=b.relation_id and a.way_id=b.way_id and a.sequence_id=0
	union all
	select  b.relation_id,a.way_id,a.node_id
	from b 
	inner join a on a.relation_id=b.relation_id and a.way_id=b.way_id and a.sequence_id=b.max_sequence_id),
d as (
	select relation_id,node_id
	from c
	group by relation_id,node_id
	having count(*) in (1,3))
select d.relation_id,r.name,string_agg(node_id::text,',' order by node_id)
from d
 inner join nodes n on n.id=node_id
 inner join regions r on st_contains(linestring,n.geom)
where not exists(select * from relation_members rm where rm.relation_id=d.relation_id and rm.member_role in ('forward','backward'))
group by d.relation_id,r.name
having count(*)>2
order by 2,1;