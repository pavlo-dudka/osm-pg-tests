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
	select  b.relation_id,a1.way_id,a1.node_id
	from b 
	inner join a a1 on a1.relation_id=b.relation_id and a1.way_id=b.way_id and a1.sequence_id=0
	inner join a a2 on a2.relation_id=b.relation_id and a2.way_id=b.way_id and a2.sequence_id=b.max_sequence_id
	where a1.node_id=a2.node_id)
select * from c
order by 1,2;