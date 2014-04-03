select '{';
select '"type": "FeatureCollection",';
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
  group by relation_id)
select '{"type":"Feature",'||
        '"properties":{'||
                       '"josm":"r'||t2.relation_id||','||string_agg(distinct 'w'||w2.id::text,',' order by 'w'||w2.id::text)||'",'||
                       '"relationtags":"name|'||replace(rtn.v,'"','\"')||'",'||
                     '},'||
        '"geometry":'||
			st_asgeojson((select (st_dumppoints(t2.geom)).geom limit 1), 5)||
       '},'
from t2
inner join relation_tags rtn on rtn.relation_id=t2.relation_id and rtn.k like 'name%'
inner join ways w2 on _st_dwithin(t2.geom,w2.linestring,0.003)
inner join way_tags wt2 on wt2.way_id=w2.id and wt2.k in ('name','addr:street') and wt2.v=rtn.v
left join relation_members rm2 on rm2.relation_id=t2.relation_id and rm2.member_id=w2.id
where rm2.member_id is null
  and not exists(select * from way_tags wt3 where wt3.way_id=w2.id and wt3.k='highway' and wt3.v in ('service','footway','platform','bus_stop'))
  and not exists(select * from exc_street_relations_n exc,relation_members rm where exc.street_relation_id_1=t2.relation_id and exc.street_relation_id_2=rm.relation_id and rm.member_id=w2.id)
  and not exists(select * from exc_street_relations_n exc,relation_members rm where exc.street_relation_id_2=t2.relation_id and exc.street_relation_id_1=rm.relation_id and rm.member_id=w2.id)
  and (wt2.k<>'addr:street' or exists(select * from way_tags wt3 where wt3.way_id=w2.id and wt3.k='addr:housenumber')) 
  --and (wt2.k<>'addr:street' or exists(select * from way_tags wt3 where wt3.way_id=w2.id and wt3.k='building'))
group by t2.relation_id,t2.geom,rtn.v
order by 1;

select '{"type":"Feature"}';
select ']}';