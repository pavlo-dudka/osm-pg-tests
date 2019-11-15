select 'api_key=24abcb162ae4b13639f58cdf4bb4c0729e11af70&q=truncate table decommunization;';
with tab as (
select cdc.koatuu,cdc.name,old_name,new_name,string_agg('w'||w.id::text,',' order by w.id) objects,array_agg(id order by id) arr 
from cityDC cdc
inner join streets_renaming sr on sr.koatuu=cdc.koatuu
inner join ways w on st_contains(cdc.linestring, w.linestring)
inner join way_tags wtn on wtn.way_id=w.id and wtn.k='name' and wtn.v in (sr.new_name,sr.old_name)
where exists(select * from way_tags where way_id=id and k='highway')
  and not exists(select * from relation_members where relation_id in (1603291,5862816,2177689,1825288,422362) and member_type='W' and member_id=w.id)
  and w.id not in (59485145,98283678,59484994,98000406,97869484,97869486,117403213,232268521,82489702,54437900)
group by cdc.koatuu,cdc.name,old_name,new_name
)
select 
'insert into decommunization(the_geom,city,old_name,new_name) values('''||
	(select st_collect(linestring)::text from ways where id=any(arr))||'''::geometry,'||
	''''||name||''','''||old_name||''','''||new_name||''');'
from tab
order by koatuu,old_name,new_name;