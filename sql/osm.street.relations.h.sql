select w.id,w2.id,wt.v,st_distance_sphere(w.linestring, w2.linestring)
from relation_tags rt
inner join relation_members rm on rm.relation_id=rt.relation_id
inner join ways w on w.id=rm.member_id and rm.member_type='W'
inner join way_tags wt on wt.way_id=w.id and wt.k='addr:housenumber'
inner join relation_members rm2 on rm2.relation_id=rt.relation_id
inner join ways w2 on w2.id=rm2.member_id and rm2.member_type='W'
inner join way_tags wt2 on wt2.way_id=w2.id and wt2.k='addr:housenumber'
where rt.k='type' and rt.v='associatedStreet'
  and w.id<w2.id and wt.v=wt2.v and st_distance_sphere(w.linestring, w2.linestring)>500
order by 4 desc