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
tags -> 'addr:housenumber' not similar to '[0-9][0-9]*[à-ÿº³]?(/[0-9][0-9]*[à-ÿ]?)?( ê[0-9][0-9]*)?|[0-9][0-9]*-[0-9][0-9]*' and
lower(tags -> 'addr:housenumber') not similar to '[0-9][0-9]*[à-ÿº³]?(/[0-9][0-9]*[à-ÿ]?)?( ê[0-9][0-9]*)?|[0-9][0-9]*-[0-9][0-9]*' and
tags -> 'addr:housenumber' not similar to '[0-9][0-9]*[a-z]?(/[0-9][0-9]*[a-z]?)?( ê[0-9][0-9]*)?|[0-9][0-9]*-[0-9][0-9]*' and
tags -> 'addr:housenumber' not similar to '[0-9][0-9]*[à-ÿº³]?(/[0-9][0-9]*[à-ÿ]?)?( ?ê ?[0-9][0-9]*)?|[0-9][0-9]*-[0-9][0-9]*' and
tags -> 'addr:housenumber' not similar to '[0-9][0-9]*-[à-ÿº³]?(/[0-9][0-9]*[à-ÿ]?)?( ?ê ?[0-9][0-9]*)?|[0-9][0-9]*-[0-9][0-9]*' and
tags -> 'addr:housenumber' not similar to '[0-9][0-9]*-[a-z]?(/[0-9][0-9]*[a-z]?)?( ?ê ?[0-9][0-9]*)?|[0-9][0-9]*-[0-9][0-9]*' and
tags -> 'addr:housenumber' not similar to '[0-9][0-9]* [à-ÿº³]?(/[0-9][0-9]*[à-ÿ]?)?( ?ê ?[0-9][0-9]*)?|[0-9][0-9]*-[0-9][0-9]*' and
tags -> 'addr:housenumber' not in ('-','*')
order by 1;