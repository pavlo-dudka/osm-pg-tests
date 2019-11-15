set client_min_messages to warning;
drop table if exists railways;
create unlogged table railways tablespace osmspace as 
select w.id, 
       w.linestring, 
       coalesce(wtl.v,'0') as layer,
       (select node_id from way_nodes wn where wn.way_id=w.id order by wn.sequence_id  asc limit 1) as node0,
       (select node_id from way_nodes wn where wn.way_id=w.id order by wn.sequence_id desc limit 1) as node1,
       (case when wt.v='rail' and wts.v is null then 'main'
             when wt.v in ('tram','subway') then wt.v
        else wts.v end) as railway_level
from ways w
  inner join way_tags wt on wt.way_id=w.id and wt.k='railway' and wt.v not in ('proposed','station','halt','platform','tram_stop','subway_entrance','engine_shed','depot','yard','roundhouse','crossing_box','signal_box','buffer_stop','ventilation_shaft')/*and wt.v in ('rail','turntable')*/
  left join  way_tags wtl on wtl.way_id=w.id and wtl.k='layer'
  left join  way_tags wts on wts.way_id=w.id and wts.k='service'
  left join  way_tags wtu on wtu.way_id=w.id and wtu.k='usage'
order by 1;
create index idx_railways_id on railways(id) tablespace osmspace;
create index idx_railways_linestring on railways using gist(linestring) tablespace osmspace;
