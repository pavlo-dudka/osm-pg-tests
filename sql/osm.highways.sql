set client_min_messages to warning;
drop table if exists highways;
create table highways as 
select w.id, w.linestring, coalesce(wtl.v,'0') as layer
from ways w
  inner join way_tags wt on wt.way_id=w.id and wt.k='highway' --and wt.v in ('motorway','motorway_link','trunk','trunk_link','primary','primary_link','secondary','secondary_link','tertiary','tertiary_link','unclassified','residential','living_street')
  left join  way_tags wtl on wtl.way_id=w.id and wtl.k='layer'
where not exists(select * from way_tags wta where wta.way_id=w.id and wta.k='area' and wta.v='yes');
create index idx_highways_id on highways(id);
create index idx_highways_linestring on highways using gist(linestring);