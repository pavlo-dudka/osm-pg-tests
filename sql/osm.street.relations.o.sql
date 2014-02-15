select '{';
select '"type": "FeatureCollection",';
select '"features": [';

with t as (
  select rt.relation_id,(st_dumppoints(w.linestring)).geom geom
  from relation_tags rt
    inner join relation_members rm on rm.relation_id=rt.relation_id and rm.member_type='W' and rm.member_role='street'
    inner join ways w on w.id=rm.member_id),
t2 as (
  select relation_id,st_collect(geom) geom
  from t
  group by relation_id),
t3 as (
  select t2.*,r.id as place_relation_id
  from t2,
    relations r inner join relation_tags rt on rt.relation_id=r.id and rt.k='place' and rt.v in ('city','town','village') and r.linestring is not null 
  where _st_crosses(r.linestring, t2.geom)),
t4 as (
  select t3.relation_id,t3.place_relation_id,st_difference(t3.geom,r.linestring) diff,st_intersection(t3.geom,r.linestring) intersection,coalesce(rt.v,'') as name,coalesce(rp.v,'') as city
  from t3
    inner join relations r on r.id=place_relation_id
    left join relation_tags rt on rt.relation_id=t3.relation_id and rt.k='name'
    left join relation_tags rp on rp.relation_id=t3.place_relation_id and rp.k='name'),
t5 as (
  select *,(select (st_dumppoints(diff)).geom limit 1) geom
  from t4
  where st_geometrytype(diff)<>'ST_Point' and st_geometrytype(intersection)<>'ST_Point')
select '{"type":"Feature",'||
        '"properties":{'||
                       '"josm":"r'||t5.relation_id||',r'||t5.place_relation_id||'",'||
                       '"relationtags":"name|'||t5.name||'",'||
                       '"city":"'||t5.city||'",'||
                     '},'||
        '"geometry":'||st_asgeojson(t5.geom,5)||
       '},'
from t5
where not exists(select * from exc_street_relations_o exc where exc.street_relation_id=t5.relation_id and exc.place_relation_id=t5.place_relation_id)
order by 1;

select '{"type":"Feature"}';
select ']}';