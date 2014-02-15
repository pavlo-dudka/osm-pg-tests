select '{';
select '"type": "FeatureCollection",';
select '"features": [';

select '{"type":"Feature",'||
        '"properties":{'||
                       '"josm":"r'||rtt.relation_id||','||string_agg(distinct 'w'||w2.id::text,',' order by 'w'||w2.id::text)||'",'||
                       '"relationtags":"name|'||replace(rtn.v,'"','\"')||'",'||
                     '},'||
        '"geometry":'||
			(select st_asgeojson(geom,5) from way_nodes wn,nodes n where wn.way_id=min(w.id) and n.id=wn.node_id and wn.sequence_id=1)||
       '},'
from relation_tags rtt
inner join relation_tags rtn on rtn.relation_id=rtt.relation_id and rtn.k='name'
inner join relation_members rm on rm.relation_id=rtt.relation_id and rm.member_role='street'
inner join ways w on w.id=rm.member_id
inner join ways w2 on st_dwithin(w.linestring,w2.linestring,0.003)
inner join way_tags wt2 on wt2.way_id=w2.id and wt2.k in ('name','addr:street') and wt2.v=rtn.v
left join relation_members rm2 on rm2.relation_id=rtt.relation_id and rm2.member_id=w2.id
where rtt.k='type' and rtt.v like '%treet' and rm2.member_id is null
  and not exists(select * from way_tags wt3 where wt3.way_id=w2.id and wt3.k='highway' and wt3.v in ('service','footway','platform','bus_stop'))
  and not exists(select * from exc_street_relations_n exc where exc.street_relation_id=rtt.relation_id and exc.way_id=w2.id)
group by rtt.relation_id,rtn.v;

select '{"type":"Feature"}';
select ']}';