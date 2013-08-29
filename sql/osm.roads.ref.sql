set client_min_messages to warning;
drop table if exists ref_roads;
create table ref_roads(id int, ref text, int_ref text, nat_ref text, reg_ref text, loc_ref text, highway text);

insert into ref_roads(id,ref,highway)
select member_id,string_agg(rtr.v, ';' order by rtr.v),'trunk'
from relation_tags rt
  inner join relation_tags rtr on rtr.relation_id=rt.relation_id and rtr.k='ref' and rtr.v like 'М-%'
  inner join relation_members rm on rm.relation_id=rt.relation_id
where rt.k='route' and rt.v='road'
  and member_id not in (select id from ref_roads)
group by rm.member_id
order by 2,1;

insert into ref_roads(id,ref,highway)
select member_id,string_agg(rtr.v, ';' order by rtr.v),'primary'
from relation_tags rt
  inner join relation_tags rtr on rtr.relation_id=rt.relation_id and rtr.k='ref' and rtr.v like 'Н-%'
  inner join relation_members rm on rm.relation_id=rt.relation_id
where rt.k='route' and rt.v='road'
  and member_id not in (select id from ref_roads)
group by rm.member_id
order by 2,1;

insert into ref_roads(id,ref,highway)
select member_id,string_agg(rtr.v, ';' order by rtr.v),'primary'
from relation_tags rt
  inner join relation_tags rtr on rtr.relation_id=rt.relation_id and rtr.k='ref' and rtr.v like 'Р-%'
  inner join relation_members rm on rm.relation_id=rt.relation_id
where rt.k='route' and rt.v='road'
  and member_id not in (select id from ref_roads)
group by rm.member_id
order by 2,1;

insert into ref_roads(id,ref,highway)
select member_id,string_agg(rtr.v, ';' order by rtr.v),'secondary'
from relation_tags rt
  inner join relation_tags rtr on rtr.relation_id=rt.relation_id and rtr.k='ref' and rtr.v like 'Т-%'
  inner join relation_members rm on rm.relation_id=rt.relation_id
where rt.k='route' and rt.v='road'
  and member_id not in (select id from ref_roads)
group by rm.member_id
order by 2,1;

insert into ref_roads(id,ref,highway)
select member_id,string_agg(rtr.v, ';' order by rtr.v),'tertiary'
from relation_tags rt
  inner join relation_tags rtr on rtr.relation_id=rt.relation_id and rtr.k='ref' and rtr.v like 'О%'
  inner join relation_members rm on rm.relation_id=rt.relation_id
where rt.k='route' and rt.v='road'
  and member_id not in (select id from ref_roads)
group by rm.member_id
order by 2,1;

insert into ref_roads(id,ref,highway)
select member_id,string_agg(rtr.v, ';' order by rtr.v),'unclassified'
from relation_tags rt
  inner join relation_tags rtr on rtr.relation_id=rt.relation_id and rtr.k='ref' and rtr.v like 'С%'
  inner join relation_members rm on rm.relation_id=rt.relation_id
where rt.k='route' and rt.v='road'
  and member_id not in (select id from ref_roads)
group by rm.member_id
order by 2,1;

insert into ref_roads(id,int_ref,highway)
select member_id,string_agg(rtr.v, ';' order by substr(rtr.v,2)::int),'trunk'
from relation_tags rt
  inner join relation_tags rtr on rtr.relation_id=rt.relation_id and rtr.k='ref' and rtr.v like 'E%'
  inner join relation_members rm on rm.relation_id=rt.relation_id
where rt.k='route' and rt.v='road'
  and member_id not in (select id from ref_roads)
group by rm.member_id
order by 2,1;

create index idx_ref_roads_id on ref_roads(id);
update ref_roads rr
set highway='trunk',int_ref=t.int_ref
from
(
  select rm.member_id, string_agg(rtr.v, ';' order by substr(rtr.v,2)::int) as int_ref
  from relation_tags rt
    inner join relation_tags rtr on rtr.relation_id=rt.relation_id and rtr.k='ref' and rtr.v like 'E%'
    inner join relation_members rm on rm.relation_id=rt.relation_id
  where rt.k='route' and rt.v='road'
  group by rm.member_id
) t
where t.member_id=rr.id;

update ref_roads rr
set nat_ref=t.nat_ref
from
(
  select rm.member_id, string_agg(rtr.v, ';' order by rtr.v) as nat_ref
  from relation_tags rt
    inner join relation_tags rtr on rtr.relation_id=rt.relation_id and rtr.k='ref' and rtr.v like 'Н-%'
    inner join relation_members rm on rm.relation_id=rt.relation_id
  where rt.k='route' and rt.v='road'
  group by rm.member_id
) t
where t.member_id=rr.id;

update ref_roads rr
set reg_ref=t.reg_ref
from
(
  select rm.member_id, string_agg(rtr.v, ';' order by rtr.v) as reg_ref
  from relation_tags rt
    inner join relation_tags rtr on rtr.relation_id=rt.relation_id and rtr.k='ref' and rtr.v like 'Р-%'
    inner join relation_members rm on rm.relation_id=rt.relation_id
  where rt.k='route' and rt.v='road'
  group by rm.member_id
) t
where t.member_id=rr.id;

update ref_roads rr
set loc_ref=t.loc_ref
from
(
  select rm.member_id, string_agg(rtr.v, ';' order by rtr.v) as loc_ref
  from relation_tags rt
    inner join relation_tags rtr on rtr.relation_id=rt.relation_id and rtr.k='ref' and rtr.v like 'Т-%-%'
    inner join relation_members rm on rm.relation_id=rt.relation_id
  where rt.k='route' and rt.v='road'
  group by rm.member_id
) t
where t.member_id=rr.id;

select 'ref:';
select rr.ref,wtr.v,string_agg(w.id::text,',' order by w.id)
from ref_roads rr
  right join ways w on w.id=rr.id
  left join way_tags wtr on wtr.way_id=w.id and wtr.k='ref'
  left join way_tags wti on wti.way_id=w.id and wti.k='int_ref'
  inner join way_tags wth on wth.way_id=w.id and wth.k='highway'
where coalesce(rr.ref,'-')<>coalesce(wtr.v,'-') 
  and not(rr.ref is null and wtr.v similar to '[ОСDLMR0-9]%|[МНР][0-9]*' or rr.ref similar to '[ОС]%' and wtr.v is null)
group by rr.ref,wtr.v
order by rr.ref,wtr.v;

select '';
select 'int_ref:';
select rr.int_ref,wti.v,string_agg(w.id::text,',' order by w.id)
from ref_roads rr
  right join ways w on w.id=rr.id
  left join way_tags wtr on wtr.way_id=w.id and wtr.k='ref'
  left join way_tags wti on wti.way_id=w.id and wti.k='int_ref'
  inner join way_tags wth on wth.way_id=w.id and wth.k='highway'
where coalesce(rr.int_ref,'-')<>coalesce(wti.v,'-')
group by rr.int_ref,wti.v
order by rr.int_ref,wti.v;

select '';
select 'nat_ref:';
select rr.nat_ref,wtn.v,string_agg(w.id::text,',' order by w.id)
from ref_roads rr
  right join ways w on w.id=rr.id
  left join way_tags wtr on wtr.way_id=w.id and wtr.k='ref'
  left join way_tags wtn on wtn.way_id=w.id and wtn.k='nat_ref'
  inner join way_tags wth on wth.way_id=w.id and wth.k='highway'
where coalesce(rr.nat_ref,'-')<>wtn.v
group by rr.nat_ref,wtn.v
order by rr.nat_ref,wtn.v;

select '';
select 'reg_ref:';
select rr.reg_ref,wtrr.v,string_agg(w.id::text,',' order by w.id)
from ref_roads rr
  right join ways w on w.id=rr.id
  left join way_tags wtr on wtr.way_id=w.id and wtr.k='ref'
  left join way_tags wtrr on wtrr.way_id=w.id and wtrr.k='reg_ref'
  inner join way_tags wth on wth.way_id=w.id and wth.k='highway'
where coalesce(rr.reg_ref,'-')<>wtrr.v
group by rr.reg_ref,wtrr.v
order by rr.reg_ref,wtrr.v;

select '';
select 'loc_ref:';
select rr.loc_ref,wtl.v,string_agg(w.id::text,',' order by w.id)
from ref_roads rr
  right join ways w on w.id=rr.id
  left join way_tags wtr on wtr.way_id=w.id and wtr.k='ref'
  left join way_tags wtl on wtl.way_id=w.id and wtl.k='loc_ref'
  inner join way_tags wth on wth.way_id=w.id and wth.k='highway'
where coalesce(rr.loc_ref,'-')<>wtl.v and wtl.v not similar to '[ОС]%'
group by rr.loc_ref,wtl.v
order by rr.loc_ref,wtl.v;

select '';
select 'highway:';
select rr.ref,rr.int_ref,rr.highway,wth.v,string_agg(w.id::text,',' order by w.id)
from ref_roads rr
  right join ways w on w.id=rr.id
  left join way_tags wtr on wtr.way_id=w.id and wtr.k='ref'
  left join way_tags wti on wti.way_id=w.id and wti.k='int_ref'
  inner join way_tags wth on wth.way_id=w.id and wth.k='highway'
where rr.highway<>wth.v and not(rr.highway='trunk' and wth.v='motorway' or rr.highway='unclassified' and wth.v in ('tertiary','residential'))
group by rr.ref,rr.int_ref,rr.highway,wth.v
order by rr.ref,rr.int_ref,rr.highway,wth.v;