set client_min_messages to warning;
drop table if exists highways;
create table highways as 
select w.id, 
       w.linestring, 
       coalesce(wtl.v,'0') as layer,
       (select node_id from way_nodes wn where wn.way_id=w.id order by wn.sequence_id  asc limit 1) as node0,
       (select node_id from way_nodes wn where wn.way_id=w.id order by wn.sequence_id desc limit 1) as node1
from ways w
  inner join way_tags wt on wt.way_id=w.id and wt.k='highway' and wt.v not in ('bus_stop','emergency_access_point','platform')
  left join  way_tags wtl on wtl.way_id=w.id and wtl.k='layer'
where not exists(select * from way_tags wta where wta.way_id=w.id and wta.k='area' and wta.v='yes');
create index idx_highways_id on highways(id);
create index idx_highways_linestring on highways using gist(linestring);