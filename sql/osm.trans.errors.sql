drop table if exists streets;

create table streets as
select trim(replace(name_uk,wtuk.type_f,'')) as uk,
       trim(replace(name_ru,wtru.type_f,'')) as ru,
       sum(cnt) as cnt,
       string_agg(ways,',' order by ways) as ways
from (
select 
--wt.v,
(case when wt2.v is not null then wt2.v 
      when wt.v similar to '%(і|ї|є|’)%' then wt.v 
      when wt.v like '% вулиця' then wt.v 
      when exists(select 1 from way_type where lang='uk' and wt.v similar to '% '||type_f||'|'||type_f||' %' and type_f<>trans) then wt.v
      else '-'
 end) as name_uk,
(case when wt3.v is not null then wt3.v 
      when wt.v similar to '%(ы|ё|ъ)%' then wt.v 
      when wt.v like '% улица' then wt.v 	
      when exists(select 1 from way_type where lang='ru' and wt.v similar to '% '||type_f||'|'||type_f||' %' and type_f<>trans) then wt.v
      else '-'
 end) as name_ru,
--wt4.v as name_en,
count(*) as cnt,
min(wt.way_id),
string_agg(wt.way_id::text,',' order by wt.way_id) as ways
from way_tags wt
left join way_tags wt2 on wt.way_id=wt2.way_id and wt2.k='name:uk'
left join way_tags wt3 on wt.way_id=wt3.way_id and wt3.k='name:ru'
--left join way_tags wt4 on wt.way_id=wt4.way_id and wt4.k='name:en'
where wt.k='name'
--and wt2.way_id is not null and wt3.way_id is not null
--and wt.v=wt3.v
group by name_uk,name_ru--,wt4.v
) t
inner join way_type wtuk on name_uk similar to ('% '||wtuk.type_f||'|'||wtuk.type_f||' %') and coalesce(wtuk.lang,'uk')='uk'
inner join way_type wtru on name_ru similar to ('% '||wtru.type_f||'|'||wtru.type_f||' %') and coalesce(wtru.lang,'ru')='ru'
where name_uk<>'-' and name_ru<>'-'
group by uk,ru
order by 1,2;
create index idx_streets_uk on streets(uk);
create index idx_streets_ru on streets(ru);

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