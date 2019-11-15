set client_min_messages to warning;
drop table if exists street_relations;
create unlogged table street_relations tablespace osmspace as 
select rt.relation_id,
       st_collect(distinct geom) geom,
       st_collect(distinct case when member_role ='street' then geom else null end) geom_streets,
       st_collect(distinct case when member_role<>'street' then geom else null end) geom_buildings,
       min(geom) geom_node
from relation_tags rt
  inner join relation_members rm on rm.relation_id=rt.relation_id and rm.member_type='W'
  inner join ways w on w.id=rm.member_id
  inner join st_dumppoints(w.linestring) p on true
where rt.k='type' and rt.v='associatedStreet'
group by rt.relation_id;
create index idx_street_relations_geom on street_relations using gist(geom) tablespace osmspace;
create index idx_street_relations_geom_streets on street_relations using gist(geom_streets) tablespace osmspace;