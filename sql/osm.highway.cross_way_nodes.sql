drop table if exists cross_way_nodes;
create unlogged table cross_way_nodes tablespace osmspace as 
with cn as (select node_id, array_agg(way_id) way_ids from way_nodes where exists(select * from highways where id=way_id) group by node_id having count(distinct way_id)>1),
wn as (select way_id_1, way_id_2, array_agg(node_id) node_ids from cn, unnest(way_ids) way_id_1,unnest(way_ids) way_id_2 where way_id_1<way_id_2 group by way_id_1,way_id_2)
select way_id_1, way_id_2, (select st_multi(st_collect(geom)) nodes_geom from nodes where id=any(node_ids)) from wn;
create index idx_cross_way_nodes_way_id on cross_way_nodes(way_id_1,way_id_2) tablespace osmspace;