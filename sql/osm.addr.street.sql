select rt.v,w.id,w.linestring 
from relation_tags rt
inner join relation_members rm on rt.relation_id=rm.relation_id and rm.member_role='street'
left join way_tags wt on way_id=member_id and wt.k='name'
inner join ways w on w.id=member_id
where rt.k='name' and (way_id is null or wt.v<>rt.v);

select *,array_length(nodes, 1) from ways where --tags ? 'building' 
--and tags ? 'highway' 
--and array_length(nodes, 1)=4
--and nodes[1] <> nodes[array_length(nodes, 1)]
tags -> 'addr:housenumber' not similar to '[0-9][0-9]*[а-яєі]?(/[0-9][0-9]*[а-я]?)?( к[0-9][0-9]*)?|[0-9][0-9]*-[0-9][0-9]*' and
lower(tags -> 'addr:housenumber') not similar to '[0-9][0-9]*[а-яєі]?(/[0-9][0-9]*[а-я]?)?( к[0-9][0-9]*)?|[0-9][0-9]*-[0-9][0-9]*' and
tags -> 'addr:housenumber' not similar to '[0-9][0-9]*[a-z]?(/[0-9][0-9]*[a-z]?)?( к[0-9][0-9]*)?|[0-9][0-9]*-[0-9][0-9]*' and
tags -> 'addr:housenumber' not similar to '[0-9][0-9]*[а-яєі]?(/[0-9][0-9]*[а-я]?)?( ?к ?[0-9][0-9]*)?|[0-9][0-9]*-[0-9][0-9]*' and
tags -> 'addr:housenumber' not similar to '[0-9][0-9]*-[а-яєі]?(/[0-9][0-9]*[а-я]?)?( ?к ?[0-9][0-9]*)?|[0-9][0-9]*-[0-9][0-9]*' and
tags -> 'addr:housenumber' not similar to '[0-9][0-9]*-[a-z]?(/[0-9][0-9]*[a-z]?)?( ?к ?[0-9][0-9]*)?|[0-9][0-9]*-[0-9][0-9]*' and
tags -> 'addr:housenumber' not similar to '[0-9][0-9]* [а-яєі]?(/[0-9][0-9]*[а-я]?)?( ?к ?[0-9][0-9]*)?|[0-9][0-9]*-[0-9][0-9]*' and
tags -> 'addr:housenumber' not in ('-','*')
order by 1;


select rtn.relation_id,wtn.way_id,rtn.k,rtn.v,wtn.v
from relation_tags rts
inner join relation_tags rtn on rtn.relation_id=rts.relation_id
inner join relation_members rm on rm.relation_id=rts.relation_id
inner join way_tags wth on wth.way_id=rm.member_id and wth.k='highway' and wth.v not like 'emerge%'
inner join way_tags wtn on wtn.way_id=rm.member_id and wtn.k=rtn.k
where rts.k='type' and rts.v in ('street','associatedStreet') and rtn.k in ('name','name:uk','name:ru') and rm.member_type='W'
and rtn.v<>wtn.v and (wtn.v not like '% міст' and wtn.v not like '% мост');