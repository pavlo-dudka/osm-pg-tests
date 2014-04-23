select 'place-way should be closed:';
select w.id
from ways w
inner join way_tags wt on wt.way_id=w.id and wt.k='place'
where st_isclosed(w.linestring)='f'
order by 1;

select '';
select 'Different errors:';
with wn as (select w2.id,w2.linestring,wtn2.v from ways w2 inner join way_tags wtn2 on wtn2.way_id=w2.id inner join way_tags wtp2 on wtp2.way_id=w2.id where wtn2.k='name' and wtp2.k='place' and st_isclosed(w2.linestring)='f'),
tab as (
select 'n'||n.id||case when w.id is null then '' else ',w'||w.id end||case when r.id is null then '' else ',r'||r.id end||
       coalesce((select ','||string_agg('w'||wn.id,',' order by wn.id) from wn where wn.v=ntn.v and _st_dwithin(wn.linestring,n.geom,1)),''),
ntn.v,ntp.v,
  coalesce((select string_agg(nt.k||'='||nt.v||'|'||wt.v,';' order by nt.k) from node_tags nt,way_tags wt where nt.node_id=n.id and wt.way_id=w.id and nt.k=wt.k and nt.v<>wt.v),
  (select string_agg(nt.k||'='||nt.v||'|'||rt.v,';' order by nt.k) from node_tags nt,relation_tags rt where nt.node_id=n.id and rt.relation_id=r.id and nt.k=rt.k and nt.v<>rt.v)) as tags,
  (case when w.id is not null and wtp.k is null and ntp.v in ('city','town') then 'missing place-tag on way; ' else '' end||
  case when r.id is not null and rtp.k is null and r.id<>1574364 and ntp.v in ('city','town') then 'missing place-tag on relation or wrong name; ' else '' end||
  case when w.id is not null and r.id is not null and ntp.v in ('city','town') then 'multiple place objects; ' else '' end||
  case when ntp.v<>wtp.v then 'node and way place-tag values are different; ' else '' end||
  case when ntp.v<>rtp.v then 'node and relation place-tag values are different; ' else '' end||
  case when w.id is null and r.id is null and ntp.v in ('city','town') then 'missing polygon; ' else '' end||
  case when exists(select * from node_tags nt,way_tags wt where nt.node_id=n.id and wt.way_id=w.id and nt.k=wt.k and nt.v<>wt.v) then 'node and way tag values are different; ' else '' end||
  case when exists(select * from node_tags nt,relation_tags rt where nt.node_id=n.id and rt.relation_id=r.id and nt.k=rt.k and nt.v<>rt.v and nt.k<>'admin_level' and (ntp.v in ('city','town') or nt.k not in ('name:en','population'))) then 'node and relation tag values are different; ' else '' end||
  case when exists(select * from wn where wn.v=ntn.v and _st_dwithin(wn.linestring,n.geom,1)) then 'non-closed way; ' else '' end) as errors
from nodes n
  inner join node_tags ntp on ntp.node_id=n.id and ntp.k='place' and ntp.v in ('city','town','village-','hamlet-')
  inner join node_tags ntn on ntn.node_id=n.id and ntn.k='name'
  left  join (select * from relation_tags inner join relations on id=relation_id and k='name') r on r.v=ntn.v and st_contains(r.linestring,n.geom)
  left  join relation_tags rtp on rtp.relation_id=r.id and rtp.k='place' 
  left  join relation_members rm on rm.relation_id=r.id and rm.member_id=n.id
  left  join (select * from way_tags inner join ways on id=way_id and k='name') w on w.v=ntn.v and st_isclosed(w.linestring) and st_contains(st_makepolygon(w.linestring),n.geom)
  left  join way_tags wtp on wtp.way_id=w.id and wtp.k='place' 
where exists(select * from regions r where st_contains(r.linestring,n.geom)))
select * from tab where errors<>''
order by 3,5,2,1;

select '';
select 'Multiple polygons:';
select count(*),n.id,string_agg(r2.id::text,',' order by r2.id),string_agg(w2.id::text,',' order by w2.id)
from 
nodes n
inner join node_tags nt on nt.node_id=n.id and nt.k='place'
left join (relations inner join relation_tags rt2 on rt2.relation_id=id and rt2.k='place' and rt2.v<>'city_district') r2 on st_contains(r2.linestring,n.geom)
left join (ways inner join way_tags wt2 on wt2.way_id=id and wt2.k='place') w2 on st_contains(w2.linestring,n.geom)
group by n.id
having count(*)>1;

select '';
select 'Invalid role:';
select * 
from relation_tags rt
inner join relation_members rm on rm.relation_id=rt.relation_id and rm.member_type='N' and rm.member_role not in ('admin_centre','label')
where rt.k='type' and rt.v in ('boundary','multipolygon')
order by 1,2,3,4,5;

select '';
select 'Invalid role:';
select * 
from relation_tags rt
inner join relation_members rm on rm.relation_id=rt.relation_id and rm.member_type='W' and rm.member_role not in ('outer','inner')
where rt.k='type' and rt.v in ('boundary','multipolygon')
order by 1,2,3,4,5;

select '';
select 'Invalid role:';
select * 
from relation_tags rt
inner join relation_members rm on rm.relation_id=rt.relation_id and rm.member_type='R' and rm.member_role not in ('subarea')
where rt.k='type' and rt.v in ('boundary','multipolygon')
order by 1,2,3,4,5;

select '';
select 'No admin_centre:';
select relation_id from relation_tags rt where k='admin_level' and v in ('4','6') 
and not exists(select * from relation_members rm where rm.relation_id=rt.relation_id and member_role='admin_centre') 
and not exists(select * from relation_tags rt2 where rt2.relation_id=rt.relation_id and rt2.v='city_district')
order by 1;

select '';
select 'name <> name:uk or invalid symbols in name:';
select node_id,max(v),min(v) from node_tags
where k in ('name','name:uk') 
  and node_id in (select node_id from node_tags where k='place' and v not in ('suburb','locality','allotments'))
  and node_id not in (371949683) 
group by node_id 
having count(distinct v)=2 or 
       min(v) not similar to '[А-Яа-яіїєІЇЄ''’ -]*' or 
       count(*)=1 and exists(select * from regions,nodes n where relation_id in (72639,1574364) and n.id=node_id and _st_contains(linestring,geom))
order by node_id;