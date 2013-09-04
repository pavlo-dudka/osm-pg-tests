select r.name,wtn.v,wtu.v,string_agg(w.id::text,',' order by w.id)
from ways w left join regions r on ST_Intersects(r.linestring,w.linestring),
non_uk left join way_tags wtr on wtr.way_id=non_uk.id and wtr.k='name:ru',
way_tags wtn,way_tags wtu,way_tags wth
where non_uk.id=w.id and wtn.way_id=w.id and wtu.way_id=w.id and wth.way_id=w.id
and wtn.k='name' and wtu.k='name:uk' and wth.k='highway'
and (r.relation_id not in (72639,71973,71971,1574364) or wtn.v<>wtr.v and wtn.v<>(wtu.v||' - '||wtr.v) and wtn.v<>(wtr.v||' - '||wtu.v))
group by r.name,wtn.v,wtu.v
order by 1 nulls first,2,3