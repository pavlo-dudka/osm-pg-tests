select * from relation_members rme
where rme.member_role like 'stop_e%' 
and not exists(select * from relation_members rmw
		inner join way_nodes wn on wn.way_id=rmw.member_id and wn.node_id=rme.member_id 
		where rme.relation_id=rmw.relation_id and rmw.member_type='W')
and not exists(select * from way_nodes where node_id=rme.member_id);