/*update way_tags wt
set v=newv
from (*/
with t as (
select w1.id, wt1.v as v1, wt2.v as v2, wt3.v as v3, wt2.way_id as road_id
from 
ways w1 
  inner join way_tags wt1 on wt1.way_id=w1.id and wt1.k in ('name','addr:street')
  left  join way_tags wth on wth.way_id=w1.id and wth.k='highway',
highways w2 
  inner join way_tags wt2 on wt2.way_id=w2.id and wt2.k='name'
  left  join way_tags wt3 on wt3.way_id=w2.id and wt3.k='name:ru'
where
 (position(lower(wt1.v) in lower(wt2.v))>0
  or wt1.k='addr:street' and position(lower(wt2.v) in lower(wt1.v))>0 and position('/' in wt1.v)=0 and position(';' in wt1.v)=0
  or wt1.k='addr:street' and levenshtein_less_equal(lower(wt1.v),lower(wt2.v),4) in (0,1,2)

  or position(lower(wt1.v) in lower(wt3.v))>0
  or wt1.k='addr:street' and position(lower(wt3.v) in lower(wt1.v))>0 and position('/' in wt1.v)=0 and position(';' in wt1.v)=0
  or wt1.k='addr:street' and levenshtein_less_equal(lower(wt1.v),lower(wt3.v),4) in (0,1,2)
  )
and st_dwithin(w1.linestring,w2.linestring,0.0025)
and wt2.v not like '% улица'
and (wt1.k='name' and wth.k is not null or wt1.k='addr:street' and wth.k is null)),
t2 as (
select id,v1 as oldv,min(v2) as newv,id||' '||string_agg(road_id::text,',') as roads
from t
group by id,v1
having count(distinct v2)=1 and v1<>min(v2))
select oldv,newv,string_agg(id::text,',' order by id) 
from t2
group by oldv,newv
order by 1,2
/*) t3
where t3.id=wt.way_id and wt.k='addr:street';*/