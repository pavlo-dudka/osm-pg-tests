drop table if exists route_roads;
create unlogged table route_roads tablespace osmspace as 
select r.id,rtr.v,rm.member_id as way_id
from relations r
inner join relation_tags rtt on rtt.relation_id=r.id and rtt.k='route' and rtt.v='road'
inner join relation_tags rtr on rtr.relation_id=r.id and rtr.k='ref'
inner join relation_members rm on rm.relation_id=r.id and rm.member_type='W'
where rtr.v similar to '([МНРТ]-|[ОС])%';
create index idx_route_roads_id on route_roads(id) tablespace osmspace;

drop table if exists route_way_nodes;
create unlogged table route_way_nodes tablespace osmspace as
select * from way_nodes where way_id in (select way_id from route_roads) and node_id in (select node_id from way_nodes group by node_id having count(*)>1);
create index idx_route_way_nodes_way_id on route_way_nodes(way_id) tablespace osmspace;

select r.*,r2.v
from route_roads r
inner join route_roads r2 on r.id<>r2.id and r.way_id=r2.way_id
where (select count(*) from route_way_nodes wn1, route_way_nodes wn2, route_roads r2 where wn1.node_id=wn2.node_id and wn1.way_id=r.way_id and wn2.way_id=r2.way_id and r.id=r2.id and r.way_id<>r2.way_id)<2
order by r.way_id,r2.v,r.id;