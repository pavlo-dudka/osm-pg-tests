vacuum;

update relations r
--  set linestring=st_simplify(t.geom,0.0001)
  set linestring=t.geom
from 
(
  select rt.relation_id as id,ST_BuildArea(st_collect(w.linestring)) geom
  from relation_tags rt 
    inner join relation_members rm on rt.relation_id=rm.relation_id and member_type='W'
    inner join ways w on w.id=rm.member_id
  where rt.k='koatuu'
  group by rt.relation_id) t
where t.id=r.id;

drop table if exists regions;
create table regions as 
select rtn.relation_id,rtn.v as name,linestring
from relations
  inner join relation_tags rtk on rtk.relation_id=id and rtk.k='koatuu' and rtk.v like '%00000000'
  inner join relation_tags rtn on rtn.relation_id=id and rtn.k='name'
order by 2;