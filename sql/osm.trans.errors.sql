drop table if exists streets;
drop table if exists way_type;

create table way_type as
select 'uk' as lang,'вулиця' as type_f,'улица' as trans union
select 'ru' as lang,'улица' as type_f,'вулиця' as trans union
select 'uk' as lang,'провулок' as type_f,'переулок' as trans union
select 'ru' as lang,'переулок' as type_f,'провулок' as trans union
select 'uk' as lang,'площа' as type_f,'площадь' as trans union
select 'ru' as lang,'площадь' as type_f,'площа' as trans union
select 'uk' as lang,'узвіз' as type_f,'спуск' as trans union
select 'uk' as lang,'проїзд' as type_f,'проезд' as trans union
select 'ru' as lang,'проезд' as type_f,'проїзд' as trans union
select 'uk' as lang,'лінія' as type_f,'линия' as trans union
select 'ru' as lang,'линия' as type_f,'лінія' as trans;

create table streets as
select substr(name_uk,1,length(name_uk)-length(wtuk.type_f)-1) as uk,
       substr(name_ru,1,length(name_ru)-length(wtru.type_f)-1) as ru,
       sum(cnt) as cnt,
       string_agg(ways,',' order by ways) as ways
from (
select 
--wt.v,
(case when wt2.v is not null then wt2.v 
      when wt.v similar to '%(і|ї|є|’)%' then wt.v 
      when wt.v similar to '% вулиця' then wt.v 
      when exists(select 1 from way_type where lang='uk' and wt.v like '%'||type_f) then wt.v
      else '-'
 end) as name_uk,
(case when wt3.v is not null then wt3.v 
      when wt.v similar to '%(ы|ё|ъ)%' then wt.v 
      when wt.v similar to '% улица' then wt.v 	
      when exists(select 1 from way_type where lang='ru' and wt.v like '%'||type_f) then wt.v      
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
inner join way_type wtuk on name_uk like '% '||wtuk.type_f and (wtuk.trans is not null or wtuk.lang is null)
inner join way_type wtru on name_ru like '% '||wtru.type_f and (wtru.trans is not null or wtru.lang is null)
where name_uk<>'-' and name_ru<>'-'
group by uk,ru
order by 1,2;

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
  inner join streets s2 on s1.uk<>s2.uk and s1.ru<>s2.ru and (s1.uk like '%'||s2.uk||'%' and s1.ru not like '%'||s2.ru||'%' or s1.uk not like '%'||s2.uk||'%' and s1.ru like '%'||s2.ru||'%')
where not exists (select * from streets s2 where s1.uk<>s2.uk and s1.ru<>s2.ru and s1.uk like '%'||s2.uk||'%' and s1.ru like '%'||s2.ru||'%')
  and s2.uk not in ('А','Б')
  and s2.ru not in ('А','Б')
order by s1.uk,s1.ru,s2.uk,s2.ru;