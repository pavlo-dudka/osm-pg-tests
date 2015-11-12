select '{';
select '"type": "FeatureCollection",';
select '"errorDescr": "Inconsistent street name on relation and object",';
select '"features": [';

select distinct '{"type":"Feature",'||
        '"properties":{'||
                       '"josm":"r'||rtt.relation_id||','||lower(rm.member_type)||rm.member_id||'",'||
                       '"relationtags":"'||rtn.k||'|'||replace(rtn.v,'"','\"')||'",'||
                       '"membertags":"'||coalesce(nt.k,wt.k,rt.k,'name')||'|'||replace(coalesce(nt.v,wt.v,rt.v,'(null)'),'"','\"')||'",'||
                       '"memberrole":"'||(case when rm.member_role='' then '(null)' else rm.member_role end)||'"'
                     '},'||
        '"geometry":'||
             case when rm.member_type='N' then (select st_asgeojson(geom,5) from nodes where id=rm.member_id)
                  when rm.member_type='W' then (select st_asgeojson(geom,5) from way_nodes wn,nodes n where wn.way_id=rm.member_id and n.id=wn.node_id and wn.sequence_id=0)
                  when rm.member_type='R' then (select st_asgeojson(geom,5) from relation_members rm2,way_nodes wn,nodes n where rm2.relation_id=rm.member_id and wn.way_id=rm2.member_id and n.id=wn.node_id and wn.sequence_id=0 and rm2.sequence_id=0)
             end||
       '},'
from relation_tags rtt
  inner join relation_members rm on rm.relation_id=rtt.relation_id 
  left join way_tags wt on rm.member_type='W' and wt.way_id=rm.member_id and (rm.member_role='street' and wt.k in ('name','name:uk','name:ru') or wt.k='addr:street')
  left join node_tags nt on rm.member_type='N' and nt.node_id=rm.member_id and nt.k='addr:street'
  left join relation_tags rt on rm.member_type='R' and rt.relation_id=rm.member_id and (rm.member_role='street' and rt.k in ('name','name:uk','name:ru') or rt.k='addr:street')
  inner join relation_tags rtn on rtn.relation_id=rtt.relation_id and (rm.member_role in ('street','') and rtn.k=coalesce(wt.k,rt.k,'name') or rm.member_role in ('house','address') and rtn.k='name')
where rtt.k='type' and rtt.v in ('street','associatedStreet')
  and (wt.v is null or wt.v not like '% міст' and wt.v not like '% мост' and wt.v not like '% шляхопровід' and wt.v not like '% путепровод')
  and (rtn.k='name' and rm.member_role not in ('street','house','address','associated')
    or rm.member_type='N' and rm.member_role='street'
    or rm.member_type='N' and not exists(select * from node_tags where node_id=rm.member_id and k='addr:housenumber')
    or rm.member_type='W' and not exists(select * from way_tags where way_id=rm.member_id)
    or rm.member_type='R' and not exists(select * from relation_tags where relation_id=rm.member_id)
    or rm.member_type='W' and rm.member_role='street' and not exists(select * from way_tags where k='name' and way_id=rm.member_id)
    or rm.member_type='R' and rm.member_role='street' and not exists(select * from relation_tags where k='name' and relation_id=rm.member_id)
    or rm.member_type='N' and rtn.k='name' and nt.k='addr:street' and nt.v<>rtn.v
       and (not exists(select * from way_type wtp where trim(replace(nt.v,type_f,''))=trim(replace(rtn.v,type_f,''))) and
            not exists(select * from relation_tags rtn2 where rtn2.relation_id=rtn.relation_id and rtn2.k in ('name:uk','name:ru') and rtn2.v=nt.v)
          or
            not exists(select * from regions r,nodes n where r.relation_id in (72639,1574364) and n.id=nt.node_id and _st_contains(r.linestring,n.geom)))
    or (rm.member_type='W' and rm.member_role='street' and coalesce(wt.k,'name')=rtn.k and coalesce(wt.v,'-')<>rtn.v) or
        rm.member_type='W' and rm.member_role in ('address','house') and rtn.k='name' and wt.k='addr:street' and wt.v<>rtn.v)
       and not exists(select * from way_tags wt2 where wt2.way_id=wt.way_id and wt2.k in ('addr2:street','addr:street2'))
       and (not exists(select * from way_type wtp where trim(replace(wt.v,type_f,''))=trim(replace(rtn.v,type_f,''))) and
            not exists(select * from relation_tags rtn2 where rtn2.relation_id=rtn.relation_id and rtn2.k in ('name:uk','name:ru') and rtn2.v=wt.v)
          or
            not exists(select * from regions r,ways w where r.relation_id in (72639,1574364) and w.id=wt.way_id and _st_contains(r.linestring,w.linestring))
    or rm.member_type='R' and rm.member_role='street' and coalesce(rt.k,'name')=rtn.k and coalesce(rt.v,'-')<>rtn.v
    or rm.member_type='R' and rtn.k='name' and rt.k='addr:street' and rt.v<>rtn.v
  )
order by 1;

select '{"type":"Feature",'||
        '"properties":{'||
                       '"josm":"r'||rtt.relation_id||'",'||
                       '"relationtags":"name|(null)"'||
                     '},'||
        '"geometry":'||
             case when rm.member_type='N' then (select st_asgeojson(geom,5) from nodes where id=rm.member_id)
                  when rm.member_type='W' then (select st_asgeojson(geom,5) from way_nodes wn,nodes n where wn.way_id=rm.member_id and n.id=wn.node_id and wn.sequence_id=0)
                  when rm.member_type='R' then (select st_asgeojson(geom,5) from relation_members rm2,way_nodes wn,nodes n where rm2.relation_id=rm.member_id and wn.way_id=rm2.member_id and n.id=wn.node_id and wn.sequence_id=0 and rm2.sequence_id=0)
             end||
       '},'
from relation_tags rtt
  left join relation_tags rtn on rtn.relation_id=rtt.relation_id and rtn.k='name'
  inner join relation_members rm on rm.relation_id=rtt.relation_id and rm.sequence_id=0
where rtt.k='type' and rtt.v in ('street','associatedStreet') and rtn.k is null
  and rtt.relation_id not in (3297198,2651279,2651280,4049546)
order by 1;

select '{"type":"Feature"}';
select ']}';