update relations r
  set linestring=t.geom
from 
(
  select rt.relation_id as id,ST_BuildArea(st_collect(w.linestring)) geom
  from relation_tags rt 
    inner join relation_members rm on rt.relation_id=rm.relation_id and member_type='W'
    left join ways w on w.id=rm.member_id
  where rt.k='type' and rt.v in ('multipolygon','boundary')
    and rt.relation_id not in (5844663,2379521,3855668,6299605,6404571,6709432,1605938,5898491,9316267,5550888,3925372,5699606,9702610,6438671)
  group by rt.relation_id
) t
where t.id=r.id;

drop table if exists regions;
create unlogged table regions tablespace osmspace as
select rtn.relation_id,rtn.v as name,linestring
from relations
  inner join relation_tags rtk on rtk.relation_id=id and rtk.k='koatuu' and rtk.v like '%00000000'
  inner join relation_tags rtn on rtn.relation_id=id and rtn.k='name'
order by 2;

drop table if exists districts;
create unlogged table districts tablespace osmspace as
select rtn.relation_id,rtn.v as name,rtk.v as koatuu,linestring
from relations
  inner join relation_tags rtk on rtk.relation_id=id and rtk.k='koatuu' and rtk.v like '%00000' and rtk.v not like '%00000000' and rtk.v not like '803%00000'
  inner join relation_tags rtn on rtn.relation_id=id and rtn.k='name'
  inner join relation_tags rta on rta.relation_id=id and rta.k='admin_level' and rta.v='6'
order by 2;
create index idx_districts_linestring on districts using gist(linestring) tablespace osmspace;
