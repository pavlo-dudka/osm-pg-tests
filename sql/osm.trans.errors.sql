drop table if exists streets;

create unlogged table streets tablespace osmspace as
select trim(replace(name_uk,wtuk.type_f,'')) as uk,
       trim(replace(name_ru,wtru.type_f,'')) as ru,
       sum(cnt) as cnt,
       (select string_agg(way, ',' order by way::int) from unnest(string_to_array(string_agg(ways,','), ',')) way) as ways
from (
select 
(case when name_uk_ is not null then name_uk_
      when name_ similar to '%(і|ї|є|’)%' then name_ 
      when exists(select 1 from way_type where lang='uk' and name_ similar to '% '||type_f||'|'||type_f||' %' and type_f<>trans) then name_
      else '-'
 end) as name_uk,
(case when name_ru_ is not null then name_ru_
      when name_ similar to '%(ы|ё|ъ)%' then name_ 
      when exists(select 1 from way_type where lang='ru' and name_ similar to '% '||type_f||'|'||type_f||' %' and type_f<>trans) then name_
      else '-'
 end) as name_ru,
sum(cnt) as cnt,
string_agg(arr, ',') as ways
from (select wt.v name_, wt2.v name_uk_, wt3.v name_ru_, string_agg(h.id::text, ',') arr, count(*) cnt
	from highways h 
	left join way_tags wt on wt.way_id=h.id and wt.k in ('name','old_name','alt_name')
	left join way_tags wt2 on wt2.way_id=h.id and wt2.k=wt.k||':uk'
	left join way_tags wt3 on wt3.way_id=h.id and wt3.k=wt.k||':ru'
	group by wt.v,wt2.v,wt3.v) wt
group by name_uk,name_ru
) t
inner join way_type wtuk on name_uk similar to ('% '||wtuk.type_f||'|'||wtuk.type_f||' %') and coalesce(wtuk.lang,'uk')='uk'
inner join way_type wtru on name_ru similar to ('% '||wtru.type_f||'|'||wtru.type_f||' %') and coalesce(wtru.lang,'ru')='ru'
where name_uk<>'-' and name_ru<>'-' and not(name_uk like '%ий майдан' and name_ru like '%ая площадь')
group by uk,ru
order by 1,2;
create index idx_streets_uk on streets(uk) tablespace osmspace;
create index idx_streets_ru on streets(ru) tablespace osmspace;

select 'uk:';
select * from streets 
where uk in (select uk from streets group by uk having count(*)>1)
order by 1,2;

select '';
select 'ru:';
select * from streets 
where ru in (select ru from streets group by ru having count(*)>1)
order by 2,1;

select '';
select '++:';
select * from streets s1
  inner join streets s2 on s1.uk<>s2.uk and s1.ru<>s2.ru and (s1.uk like '%'||s2.uk and s1.ru not like '%'||s2.ru or s1.uk not like '%'||s2.uk and s1.ru like '%'||s2.ru)
where not exists (select * from streets s2 where s1.uk<>s2.uk and s1.ru<>s2.ru and s1.uk like '%'||s2.uk and s1.ru like '%'||s2.ru 
                                             and s2.uk not in ('А','Б','1-й','2-й','3-й') 
                                             and s2.ru not in ('А','Б','1-й','2-й','3-й'))
  and s2.uk not in ('А','Б','1-й','2-й','3-й') 
  and s2.ru not in ('А','Б','1-й','2-й','3-й')
order by s1.uk,s1.ru,s2.uk,s2.ru;

select '';
select 'uk2:';
select regexp_replace(ru,'[0-9]*-[аяйї] ',''),* from streets 
where regexp_replace(ru,'[0-9]*-[аяйї] ','') in (select regexp_replace(ru,'[0-9]*-[аяйї] ','') from streets where ru not in (select ru from streets group by ru having count(*)>1) group by regexp_replace(ru,'[0-9]*-[аяйї] ','') having count(distinct regexp_replace(uk,'[0-9]*-[аяйї] ',''))>1)
order by 1,2;

select '';
select 'ru2:';
select regexp_replace(uk,'[0-9]*-[аяйї] ',''),* from streets 
where regexp_replace(uk,'[0-9]*-[аяйї] ','') in (select regexp_replace(uk,'[0-9]*-[аяйї] ','') from streets where uk not in (select uk from streets group by uk having count(*)>1) group by regexp_replace(uk,'[0-9]*-[аяйї] ','') having count(distinct regexp_replace(ru,'[0-9]*-[аяйї] ',''))>1)
order by 1,2;

select '';
select 'No name-tag:';
select way_id,max(v) from way_tags where k like 'name%' group by way_id having min(k)<>'name' order by 1;

select '';
select 'Unknown language:';
select v,string_agg(way_id::text,',' order by way_id) 
from way_tags, way_type
where k='name' and v like '% '||type_f and replace(v,' '||type_f,'') not in (select uk from streets union select ru from streets) and replace(replace(v,' '||type_f,''),' '||trans,'') not in (select uk||' - '||ru from streets union select ru||' - '||uk from streets)
  and lang is null
group by v
order by 1;

select '';
select 'Inconsistent way-type:';
select id,wt.v,wtu.v,wtr.v
from highways 
inner join way_tags wt on wt.way_id=id and wt.k='name'
left join way_tags wtu on wtu.way_id=id and wtu.k='name:uk'
inner join way_tags wtr on wtr.way_id=id and wtr.k='name:ru'
where exists(select * from way_type where coalesce(wtu.v,wt.v) similar to type_f||' %|% '||type_f and coalesce(lang,'uk')='uk' and trans is not null)
  and not exists(select * from way_type where coalesce(wtu.v,wt.v) similar to type_f||' %|% '||type_f and coalesce(lang,'uk')='uk' and lower(wtr.v) similar to trans||' %|% '||trans and trans is not null)
  and wt.v<>wtr.v
union
select id,wt.v,wtu.v,wtr.v
from highways 
inner join way_tags wt on wt.way_id=id and wt.k='name'
left join way_tags wtu on wtu.way_id=id and wtu.k='name:uk'
inner join way_tags wtr on wtr.way_id=id and wtr.k='name:ru'
where exists(select * from way_type where wtr.v similar to trans||' %|% '||trans and coalesce(lang,'uk')='uk' and trans is not null)
  and not exists(select * from way_type where coalesce(wtu.v,wt.v) similar to type_f||' %|% '||type_f and coalesce(lang,'uk')='uk' and wtr.v similar to trans||' %|% '||trans and trans is not null)
  and wt.v<>wtr.v
  and wtr.v not similar to '% (спуск|площадь)'  
order by 1;

select '';
select 'Add street-relation';
select distinct w.id,wt.v
from highways w 
inner join way_tags wt on wt.way_id=w.id and wt.k in ('name','name:uk','name:ru')
left  join way_tags wtu on wtu.way_id=w.id and wtu.k='name:uk'
where not exists(select * from relation_tags rt,relation_members rm where rt.relation_id=rm.relation_id and rt.k='type' and rt.v='associatedStreet' and rm.member_id=w.id and rm.member_type='W')
  and exists(select * from way_tags wt2, ways w2, way_tags wt3 where wt2.way_id=w2.id and wt3.way_id=w2.id and wt2.k='addr:street' and wt3.k='addr:housenumber' and wt2.v=wt.v and _st_dwithin(w.linestring,w2.linestring,0.01))
  and exists(select * from way_type where lang='ru' and (wt.v like '% '||type_f or wt.v like type_f||'% '))
  and wtu.way_id is null
  and highway_level<>'service'
order by 1,2;

select distinct w.id,wt.v
from highways w 
inner join way_tags wt on wt.way_id=w.id and wt.k in ('name','name:uk','name:ru')
left  join way_tags wtu on wtu.way_id=w.id and wtu.k='name:uk'
where not exists(select * from relation_tags rt,relation_members rm where rt.relation_id=rm.relation_id and rt.k='type' and rt.v='associatedStreet' and rm.member_id=w.id and rm.member_type='W')
  and exists(select * from way_tags wt2, ways w2, way_tags wt3 where wt2.way_id=w2.id and wt3.way_id=w2.id and wt2.k='addr:street' and wt3.k='addr:housenumber' and wt2.v=wt.v and _st_dwithin(w.linestring,w2.linestring,0.01))
  and wt.v<>wtu.v
  and highway_level<>'service'
order by 1,2;