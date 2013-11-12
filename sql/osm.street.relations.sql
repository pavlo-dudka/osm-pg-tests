select '{';
select '"type": "FeatureCollection",';
select '"features": [';

select '{"type":"Feature",'||
        '"properties":{'||
                       '"josm":"r'||rtt.relation_id||','||lower(rm.member_type)||rm.member_id||'",'||
                       '"relationtags":"'||rtn.k||'|'||replace(rtn.v,'"','\"')||'",'||
                       '"membertags":"'||coalesce(nt.k,wt.k,rt.k,'name')||'|'||replace(coalesce(nt.v,wt.v,rt.v,'(null)'),'"','\"')||'"'||
                     '},'||
        '"geometry":'||
             case when rm.member_type='N' then (select st_asgeojson(geom,5) from nodes where id=rm.member_id)
                  when rm.member_type='W' then (select st_asgeojson(geom,5) from way_nodes wn,nodes n where wn.way_id=rm.member_id and n.id=wn.node_id and wn.sequence_id=0)
                  when rm.member_type='R' then (select st_asgeojson(geom,5) from relation_members rm2,way_nodes wn,nodes n where rm2.relation_id=rm.member_id and wn.way_id=rm2.member_id and n.id=wn.node_id and wn.sequence_id=0 and rm2.sequence_id=0)
             end||
       '},'
from relation_tags rtt
  inner join relation_tags rtn on rtn.relation_id=rtt.relation_id and rtn.k in ('name','name:uk','name:ru','name:en-')
  inner join relation_members rm on rm.relation_id=rtt.relation_id 
  left join way_tags wt on rm.member_type='W' and wt.way_id=rm.member_id and (rm.member_role='street' and wt.k=rtn.k or rtn.k='name' and wt.k='addr:street')
  left join node_tags nt on rm.member_type='N' and nt.node_id=rm.member_id and (rm.member_role='street' or rtn.k='name' and nt.k='addr:street')
  left join relation_tags rt on rm.member_type='R' and rt.relation_id=rm.member_id and (rm.member_role='street' and rt.k=rtn.k or rtn.k='name' and rt.k='addr:street')
where rtt.k='type' and rtt.v in ('street','associatedStreet')
  and (wt.v is null or wt.v not like '% міст' and wt.v not like '% мост')
  and (
     rm.member_type='N' and (rm.member_role='street' or rtn.k='name' and nt.k='addr:street' and nt.v<>rtn.v) or
     rm.member_type='R' and (rm.member_role='street' and (coalesce(rt.k,'name')=rtn.k and coalesce(rt.v,'-')<>rtn.v) or rtn.k='name' and rt.k='addr:street' and rt.v<>rtn.v) or
     rm.member_type='W' and (rm.member_role='street' and (coalesce(wt.k,'name')=rtn.k and coalesce(wt.v,'-')<>rtn.v) or rm.member_role in ('address','house') and rtn.k='name' and wt.k='addr:street' and wt.v<>rtn.v) and not exists(select * from way_tags wt2 where wt2.way_id=wt.way_id and wt2.k in ('addr2:street','addr:street2'))
  )
order by rtt.relation_id,rm.member_id;

select '{"type":"Feature"}';
select ']}';