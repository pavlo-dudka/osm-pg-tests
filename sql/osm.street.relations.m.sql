select '{';
select '"type": "FeatureCollection",';
select '"errorDescr": "Object included to multiple relations",';
select '"features": [';

select '{"type":"Feature",'||
        '"properties":{'||
                       '"josm":"'||lower(rm.member_type)||rm.member_id||','||string_agg('r'||rt.relation_id,',' order by rt.relation_id)||'",'||
                       '"relationtags":"'||string_agg(rtn.k||'|'||replace(rtn.v,'"','\"'),'&' order by rt.relation_id)||'",'||
                       '"addrhousenumber":"'||coalesce(nt.v,wt.v,'')||'"'||
                     '},'||
        '"geometry":'||
             case when rm.member_type='N' then (select st_asgeojson(geom,5) from nodes where id=rm.member_id)
                  when rm.member_type='W' then (select st_asgeojson(geom,5) from way_nodes wn,nodes n where wn.way_id=rm.member_id and n.id=wn.node_id and wn.sequence_id=0)
                  when rm.member_type='R' then (select st_asgeojson(geom,5) from relation_members rm2,way_nodes wn,nodes n where rm2.relation_id=rm.member_id and wn.way_id=rm2.member_id and n.id=wn.node_id and wn.sequence_id=0 and rm2.sequence_id=0)
             end||
       '},'
from relation_tags rt
inner join relation_members rm on rm.relation_id=rt.relation_id and rm.member_role <> 'is_in'
left join relation_tags rtn on rtn.relation_id=rt.relation_id and rtn.k='name'
left join node_tags nt on nt.node_id=rm.member_id and rm.member_type='N' and nt.k='addr:housenumber'
left join way_tags wt on wt.way_id=rm.member_id and rm.member_type='W' and wt.k='addr:housenumber'
where rt.k='type' and rt.v in ('street','associatedStreet')
group by rm.member_id,rm.member_type,nt.k,nt.v,wt.k,wt.v
having count(*)>1 and not exists(select * from exc_street_relations_n where street_relation_id_1=min(rm.relation_id) and street_relation_id_2=max(rm.relation_id) and 'street'=min(rm.member_role))
order by 1;

select '{"type":"Feature"}';
select ']}';