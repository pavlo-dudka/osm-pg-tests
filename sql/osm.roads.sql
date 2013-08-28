drop table if exists route_roads;
create table route_roads as 
select r.id,rtr.v,rm.member_id as way_id
from relations r
inner join relation_tags rtt on rtt.relation_id=r.id and rtt.k='route' and rtt.v='road'
inner join relation_tags rtr on rtr.relation_id=r.id and rtr.k='ref'
inner join relation_members rm on rm.relation_id=r.id and rm.member_type='W'
where rtr.v similar to '([МНРТ]-|[ОС])%';
create index idx_route_roads_id on route_roads(id);

drop table if exists route_way_nodes;
create table route_way_nodes as
select * from way_nodes where way_id in (select way_id from route_roads) and node_id in (select node_id from way_nodes group by node_id having count(*)>1);
create index idx_route_way_nodes_way_id on route_way_nodes(way_id);

select r.*,r2.v
from route_roads r
inner join route_roads r2 on r.id<>r2.id and r.way_id=r2.way_id
where (select count(*) from route_way_nodes wn1, route_way_nodes wn2, route_roads r2 where wn1.node_id=wn2.node_id and wn1.way_id=r.way_id and wn2.way_id=r2.way_id and r.id=r2.id and r.way_id<>r2.way_id)<2
order by 2;

/*select rr.v,sum(st_length(ST_Transform(w.linestring,2163)) * (case when wt.v is null then 1 else 0.5 end))
from route_roads rr 
inner join ways w on w.id=rr.way_id 
left join way_tags wt on wt.k='oneway' and wt.v<>'no' and wt.way_id=rr.way_id
where rr.v='Н-11'
group by rr.v
order by 1;*/