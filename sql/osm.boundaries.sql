vacuum;

update relations r
  set linestring=t.geom
from 
(
  select rt.relation_id as id,ST_BuildArea(st_collect(w.linestring)) geom
  from relation_tags rt 
    inner join relation_members rm on rt.relation_id=rm.relation_id and member_type='W'
    left join ways w on w.id=rm.member_id
  where rt.k='type' and rt.v in ('multipolygon','boundary')
    and rt.relation_id not in (2379521,2469245,1744377,3456939)
  group by rt.relation_id
  having min(case when st_isvalid(w.linestring)='t' then 1 else 0 end)=1) t
where t.id=r.id;

drop table if exists regions;
create table regions as 
select rtn.relation_id,rtn.v as name,linestring
from relations
  inner join relation_tags rtk on rtk.relation_id=id and rtk.k='koatuu' and rtk.v like '%00000000'
  inner join relation_tags rtn on rtn.relation_id=id and rtn.k='name'
order by 2;