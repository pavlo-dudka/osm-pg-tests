update cityDC cdc
set linestring = tab.linestring, name=tab.city_name
from
  (select r.linestring, nt.v koatuu, ntn.v city_name
   from node_tags nt 
     inner join node_tags ntn on ntn.node_id=nt.node_id and ntn.k='name'
     inner join nodes n on n.id=ntn.node_id
     inner join relations r on st_contains(r.linestring,n.geom)
     inner join relation_tags rtk on rtk.relation_id=r.id and rtk.k='name' and rtk.v=ntn.v and rtk.relation_id in (select relation_id from relation_tags where k='place')
   where nt.k='koatuu' and nt.v in (select koatuu from cityDC)) tab
where tab.koatuu=cdc.koatuu;

update cityDC cdc
set linestring = tab.linestring, name=tab.city_name
from
  (select st_makepolygon(w.linestring) linestring, nt.v koatuu, ntn.v city_name
   from node_tags nt 
     inner join node_tags ntn on ntn.node_id=nt.node_id and ntn.k='name'
     inner join nodes n on n.id=ntn.node_id
     inner join way_tags wtk on wtk.k='name' and wtk.v=ntn.v and wtk.way_id in (select way_id from way_tags where k='place')
     inner join ways w on wtk.way_id=w.id and st_isclosed(w.linestring) and st_contains(st_makepolygon(w.linestring),n.geom)
   where nt.k='koatuu' and nt.v in (select koatuu from cityDC where linestring is null)) tab
where tab.koatuu=cdc.koatuu;

select '{';
select '"type": "FeatureCollection",';
select '"errorDescr": "",';
select '"no_markers": "true",';
select '"features": [';

with tab as (
select cdc.koatuu,cdc.name,old_name,new_name,string_agg('w'||w.id::text,',' order by w.id) objects,array_agg(id order by id) arr 
from cityDC cdc
inner join streets_renaming sr on sr.koatuu=cdc.koatuu
inner join ways w on st_contains(cdc.linestring, w.linestring)
inner join way_tags wtn on wtn.way_id=w.id and wtn.k='name' and wtn.v=sr.old_name
where exists(select * from way_tags where way_id=id and k='highway')
  and not exists(select * from relation_members where relation_id in (1603291,5862816,2177689,1825288,422362,5694366) and member_type='W' and member_id=w.id)
  and w.id not in (59485145,98283678,59484994,98000406,97869484,97869486,117403213,232268521,54437900)
group by cdc.koatuu,cdc.name,old_name,new_name
)
select '{"type":"Feature","properties":{"koatuu":"'||koatuu||'","city":"'||name||'","josm":"'||objects||'","old_name":"'||old_name||'","new_name":"'||new_name||'","error":"not renamed yet"},'||
       '"geometry":'||(select st_asgeojson(st_collect(linestring),5) from ways where id=any(arr))||'},'
from tab
order by koatuu,old_name,new_name;

with tab as (
select cdc.koatuu,cdc.name,old_name,new_name,string_agg('w'||w.id::text,',' order by w.id) objects,array_agg(id order by id) arr 
from cityDC cdc
inner join streets_renaming sr on sr.koatuu=cdc.koatuu
inner join ways w on st_contains(cdc.linestring, w.linestring)
inner join way_tags wtn on wtn.way_id=w.id and wtn.k='addr:street' and wtn.v=sr.old_name
where not exists(select * from relation_members where relation_id in (1603291,5862816,2177689,1825288,422362,5694366) and member_type='W' and member_id=w.id)
group by cdc.koatuu,cdc.name,old_name,new_name
)
select '{"type":"Feature","properties":{"koatuu":"'||koatuu||'","city":"'||name||'","josm":"'||objects||'","old_name":"'||old_name||'","new_name":"'||new_name||'","error":"not renamed yet"},'||
       '"geometry":'||(select st_asgeojson(st_collect(linestring),5) from ways where id=any(arr))||'},'
from tab
order by koatuu,old_name,new_name;

with tab as (
select cdc.koatuu,cdc.name,old_name,string_agg(distinct new_name,',') new_name,string_agg('w'||w.id::text,',' order by w.id) objects,array_agg(id order by id) arr
from cityDC cdc
inner join streets_renaming sr on sr.koatuu=cdc.koatuu
inner join ways w on st_contains(cdc.linestring, w.linestring)
inner join way_tags wto on wto.way_id=w.id and wto.k='old_name' and wto.v=sr.old_name
inner join way_tags wtn on wtn.way_id=w.id and wtn.k='name'
where exists(select * from way_tags where way_id=id and k='highway')
  and not exists(select * from relation_members where relation_id in (1603291,5862816,1825288,422362,6463619) and member_type='W' and member_id=w.id)
group by cdc.koatuu,cdc.name,old_name,wtn.v
having not wtn.v=any(array_agg(new_name))
)
select '{"type":"Feature","properties":{"koatuu":"'||koatuu||'","city":"'||name||'","josm":"'||objects||'","old_name":"'||old_name||'","new_name":"'||new_name||'","error":"wrong name"},'||
       '"geometry":'||(select st_asgeojson(st_collect(linestring),5) from ways where id=any(arr))||'},'
from tab
order by koatuu,old_name,new_name;

with tab as (
select cdc.koatuu,cdc.name,old_name,new_name,string_agg('w'||w.id::text,',' order by w.id) objects,array_agg(id order by id) arr 
from cityDC cdc
inner join streets_renaming sr on sr.koatuu=cdc.koatuu
inner join ways w on st_contains(cdc.linestring, w.linestring)
inner join way_tags wtn on wtn.way_id=w.id and wtn.k='name' and wtn.v=sr.new_name
inner join way_tags wto on wto.way_id=w.id and wto.k='old_name'
where exists(select * from way_tags where way_id=id and k='highway')
  and coalesce(wto.v,'-')<>sr.old_name
  and w.id not in (295127201,351926330,82489702,267064327,29908029,77522483)
group by cdc.koatuu,cdc.name,old_name,new_name
)
select '{"type":"Feature","properties":{"koatuu":"'||koatuu||'","city":"'||name||'","josm":"'||objects||'","old_name":"'||old_name||'","new_name":"'||new_name||'","error":"wrong or missing old_name"},'||
       '"geometry":'||(select st_asgeojson(st_collect(linestring),5) from ways where id=any(arr))||'},'
from tab
order by koatuu,old_name,new_name;
	
select '{"type":"Feature"}';
select ']}';