update relations r
  set linestring=st_simplify(t.geom,0.0001)
from 
(
  select rt.relation_id as id,ST_BuildArea(st_collect(w.linestring)) geom
  from relation_tags rt 
    inner join relation_members rm on rt.relation_id=rm.relation_id and member_type='W'
    inner join ways w on w.id=rm.member_id
  where rt.k='koatuu'
  group by rt.relation_id) t
where t.id=r.id;
update regions set linestring=(select linestring from relations where id=relation_id);