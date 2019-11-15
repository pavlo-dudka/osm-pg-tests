set client_min_messages to warning;
drop table if exists highways;
create unlogged table highways tablespace osmspace as 
select w.id, 
       w.linestring, 
       coalesce(wtl.v,'0') as layer,
       (select node_id from way_nodes wn where wn.way_id=w.id order by wn.sequence_id  asc limit 1) as node0,
       (select node_id from way_nodes wn where wn.way_id=w.id order by wn.sequence_id desc limit 1) as node1,
       wt.v as highway_level
from ways w
  inner join way_tags wt on wt.way_id=w.id and wt.k in ('highway','aeroway') and wt.v in ('motorway','motorway_link','trunk','trunk_link','primary','primary_link','secondary','secondary_link','tertiary','tertiary_link','unclassified','residential','living_street','service','pedestrian','construction','runway','taxiway','steps--')
  left  join way_tags wtl on wtl.way_id=w.id and wtl.k='layer'
where not exists(select * from way_tags wta where wta.way_id=w.id and wta.k='area' and wta.v='yes')
  and not(wt.v='construction' and exists(select * from exc_highways where way_id=w.id))
  and not(wt.v='construction' and exists(select * from relation_members where relation_id=7150834 and member_id=w.id));
create index idx_highways_id on highways(id) tablespace osmspace;
create index idx_highways_linestring on highways using gist(linestring) tablespace osmspace;