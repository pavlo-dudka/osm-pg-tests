select '{';
select '"type": "FeatureCollection",';
select '"features": [';
select '{"type":"Feature","properties":{"josm":"w'||wn1.way_id||',n'||wn2.node_id||'"},"geometry":'||st_asgeojson(n2.geom,5)||'},'
from way_nodes wn1, way_nodes wn2, way_nodes wn3, way_nodes wn4,
nodes n1, nodes n2, nodes n3, nodes n4,
way_tags wt
where wn1.way_id=wn2.way_id and wn1.way_id=wn3.way_id and wn1.way_id=wn4.way_id and
wn1.sequence_id+1=wn2.sequence_id and wn2.sequence_id=wn3.sequence_id-1 and wn2.sequence_id=wn4.sequence_id-2
and n1.id=wn1.node_id and n2.id=wn2.node_id and n3.id=wn3.node_id and n4.id=wn4.node_id 
and (abs(ST_Azimuth(n1.geom,n2.geom)-ST_Azimuth(n2.geom,n3.geom))/pi() between 0.45 and 1.55
 and abs(ST_Azimuth(n2.geom,n3.geom)-ST_Azimuth(n3.geom,n4.geom))/pi() between 0.45 and 1.55
 and st_distance_sphere(n2.geom,n3.geom) < 4
 or
     abs(ST_Azimuth(n1.geom,n2.geom)-ST_Azimuth(n2.geom,n3.geom))/pi() between 0.8 and 1.2
 and abs(ST_Azimuth(n2.geom,n3.geom)-ST_Azimuth(n3.geom,n4.geom))/pi() between 0.8 and 1.2
)
and wt.way_id=wn1.way_id and wt.k='highway'
order by wn1.way_id,wn1.sequence_id;
select ']}';