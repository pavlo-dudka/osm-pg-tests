select '{';
select '"type": "FeatureCollection",';
select '"errorDescr": "Objects not in relation",';
select '"features": [';

with /*t as (
  select rt.relation_id,(st_dumppoints(w.linestring)).geom geom
  from relation_tags rt
    inner join relation_members rm on rm.relation_id=rt.relation_id and rm.member_type='W' --and rm.member_role='street'
    inner join ways w on w.id=rm.member_id
  where rt.k='type' and rt.v='associatedStreet'),
t2 as (
  select t.relation_id,st_collect(distinct geom) geom, min(geom) geom_node, rtn.v rel_name
  from t
   inner join relation_tags rtn on rtn.relation_id=t.relation_id and rtn.k in ('name','name:uk','name:ru')
  group by t.relation_id,rtn.v),*/
t2 as (
  select distinct t.relation_id, t.geom, t.geom_node, rtn.v rel_name
  from street_relations t
   inner join relation_tags rtn on rtn.relation_id=t.relation_id and rtn.k in ('name','name:uk','name:ru')),
t3 as (
select t2.relation_id,'w'||w2.id obj_id,t2.geom_node
from t2
inner join ways w2 on _st_dwithin(t2.geom,w2.linestring,0.01)
inner join way_tags wt2 on wt2.way_id=w2.id and wt2.k='name' and wt2.v=t2.rel_name
where not exists(select * from relation_members rm2 where rm2.relation_id=t2.relation_id and rm2.member_id=w2.id)
  and     exists(select * from way_tags wt3 where wt3.way_id=w2.id and wt3.k='highway')
  and not exists(select * from way_tags wt3 where wt3.way_id=w2.id and wt3.k='highway' and wt3.v in ('track','service','footway','platform','bus_stop'))
  and not exists(select * from exc_street_relations_n exc,relation_members rm where exc.street_relation_id_1=t2.relation_id and exc.street_relation_id_2=rm.relation_id and rm.member_id=w2.id)
  and not exists(select * from exc_street_relations_n exc,relation_members rm where exc.street_relation_id_2=t2.relation_id and exc.street_relation_id_1=rm.relation_id and rm.member_id=w2.id)
union all
select t2.relation_id,'w'||w2.id obj_id,t2.geom_node
from t2
inner join ways w2 on _st_dwithin(t2.geom,w2.linestring,0.01)
inner join way_tags wt2 on wt2.way_id=w2.id and wt2.k='addr:street' and wt2.v=t2.rel_name
where not exists(select * from relation_members rm2 where rm2.relation_id=t2.relation_id and rm2.member_id=w2.id)
  and not exists(select * from exc_street_relations_n exc,relation_members rm where exc.street_relation_id_1=t2.relation_id and exc.street_relation_id_2=rm.relation_id and rm.member_id=w2.id)
  and not exists(select * from exc_street_relations_n exc,relation_members rm where exc.street_relation_id_2=t2.relation_id and exc.street_relation_id_1=rm.relation_id and rm.member_id=w2.id)
  and exists(select * from way_tags wt3 where wt3.way_id=w2.id and wt3.k in ('addr:housenumber','addr:interpolation'))
union all
select t2.relation_id,'r'||w2.id obj_id,t2.geom_node
from t2
inner join relations w2 on _st_dwithin(t2.geom,w2.linestring,0.01)
inner join relation_tags wt2 on wt2.relation_id=w2.id and wt2.k='addr:street' and wt2.v=t2.rel_name
where not exists(select * from relation_members rm2 where rm2.relation_id=t2.relation_id and rm2.member_id=w2.id)
  and not exists(select * from exc_street_relations_n exc,relation_members rm where exc.street_relation_id_1=t2.relation_id and exc.street_relation_id_2=rm.relation_id and rm.member_id=w2.id)
  and not exists(select * from exc_street_relations_n exc,relation_members rm where exc.street_relation_id_2=t2.relation_id and exc.street_relation_id_1=rm.relation_id and rm.member_id=w2.id)
  and exists(select * from relation_tags wt3 where wt3.relation_id=w2.id and wt3.k='addr:housenumber'))
select '{"type":"Feature",'||
        '"properties":{'||
                       '"josm":"r'||t3.relation_id||','||string_agg(distinct obj_id,',' order by obj_id)||'",'||
                       '"relationtags":"name|'||rtn.v||'"'||
                     '},'||
        '"geometry":'||
			st_asgeojson(t3.geom_node, 5)||
       '},'
from t3
inner join relation_tags rtn on rtn.relation_id=t3.relation_id and rtn.k='name'
group by t3.relation_id,t3.geom_node,rtn.v
order by 1;

select '{"type":"Feature"}';
select ']}';
