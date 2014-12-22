select '{';
select '"type": "FeatureCollection",';
select '"errorDescr": "Objects not in relation",';
select '"features": [';

with t as (
  select rt.relation_id,(st_dumppoints(w.linestring)).geom geom
  from relation_tags rt
    inner join relation_members rm on rm.relation_id=rt.relation_id and rm.member_type='W' --and rm.member_role='street'
    inner join ways w on w.id=rm.member_id
  where rt.k='type' and rt.v='associatedStreet'),
t2 as (
  select relation_id,st_collect(geom) geom
  from t
  group by relation_id),
t3 as (
/*select distinct t2.relation_id,'n'||w2.id obj_id,replace(rtn.v,'"','\"') rel_name,t2.geom
from t2
inner join relation_tags rtn on rtn.relation_id=t2.relation_id and rtn.k in ('name','name:uk','name:ru')
inner join nodes w2 on _st_dwithin(t2.geom,w2.geom,0.01)
inner join node_tags wt2 on wt2.node_id=w2.id and wt2.k in ('addr:street') and wt2.v=rtn.v
where not exists(select * from relation_members rm2 where rm2.relation_id=t2.relation_id and rm2.member_id=w2.id)
  and not exists(select * from way_tags wt3 where wt3.way_id=w2.id and wt3.k='highway' and wt3.v in ('service','footway','platform','bus_stop'))
  and not exists(select * from exc_street_relations_n exc,relation_members rm where exc.street_relation_id_1=t2.relation_id and exc.street_relation_id_2=rm.relation_id and rm.member_id=w2.id)
  and not exists(select * from exc_street_relations_n exc,relation_members rm where exc.street_relation_id_2=t2.relation_id and exc.street_relation_id_1=rm.relation_id and rm.member_id=w2.id)
  and exists(select * from node_tags wt3 where wt3.node_id=w2.id and wt3.k in ('addr:housenumber','addr:interpolation'))
union*/
select distinct t2.relation_id,'w'||w2.id obj_id,replace(rtn.v,'"','\"') rel_name,t2.geom
from t2
inner join relation_tags rtn on rtn.relation_id=t2.relation_id and rtn.k in ('name','name:uk','name:ru')
inner join ways w2 on _st_dwithin(t2.geom,w2.linestring,0.01)
inner join way_tags wt2 on wt2.way_id=w2.id and wt2.k in ('name','addr:street') and wt2.v=rtn.v
where not exists(select * from relation_members rm2 where rm2.relation_id=t2.relation_id and rm2.member_id=w2.id)
  and not exists(select * from way_tags wt3 where wt3.way_id=w2.id and wt3.k='highway' and wt3.v in ('service','footway','platform','bus_stop'))
  and not exists(select * from exc_street_relations_n exc,relation_members rm where exc.street_relation_id_1=t2.relation_id and exc.street_relation_id_2=rm.relation_id and rm.member_id=w2.id)
  and not exists(select * from exc_street_relations_n exc,relation_members rm where exc.street_relation_id_2=t2.relation_id and exc.street_relation_id_1=rm.relation_id and rm.member_id=w2.id)
  and (wt2.k<>'addr:street' or exists(select * from way_tags wt3 where wt3.way_id=w2.id and wt3.k in ('addr:housenumber','addr:interpolation')))
union
select distinct t2.relation_id,'r'||w2.id obj_id,replace(rtn.v,'"','\"') rel_name,t2.geom
from t2
inner join relation_tags rtn on rtn.relation_id=t2.relation_id and rtn.k in ('name','name:uk','name:ru')
inner join relations w2 on _st_dwithin(t2.geom,w2.linestring,0.01)
inner join relation_tags wt2 on wt2.relation_id=w2.id and wt2.k in ('addr:street') and wt2.v=rtn.v
where not exists(select * from relation_members rm2 where rm2.relation_id=t2.relation_id and rm2.member_id=w2.id)
  and not exists(select * from way_tags wt3 where wt3.way_id=w2.id and wt3.k='highway' and wt3.v in ('service','footway','platform','bus_stop'))
  and not exists(select * from exc_street_relations_n exc,relation_members rm where exc.street_relation_id_1=t2.relation_id and exc.street_relation_id_2=rm.relation_id and rm.member_id=w2.id)
  and not exists(select * from exc_street_relations_n exc,relation_members rm where exc.street_relation_id_2=t2.relation_id and exc.street_relation_id_1=rm.relation_id and rm.member_id=w2.id)
  and exists(select * from relation_tags wt3 where wt3.relation_id=w2.id and wt3.k in ('addr:housenumber','addr:interpolation')))
select '{"type":"Feature",'||
        '"properties":{'||
                       '"josm":"r'||t3.relation_id||','||string_agg(distinct obj_id,',' order by obj_id)||'",'||
                       '"relationtags":"name|'||rel_name||'",'||
                     '},'||
        '"geometry":'||
			st_asgeojson((select (st_dumppoints(t3.geom)).geom limit 1), 5)||
       '},'
from t3
group by t3.relation_id,t3.geom,t3.rel_name
order by 1;

select '{"type":"Feature"}';
select ']}';