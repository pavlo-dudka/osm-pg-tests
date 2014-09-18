drop table if exists koatuu;
create table koatuu(code text, place text, title text);
copy koatuu from 'osm/koatuu.csv' delimiter ',' csv quote '"';
update koatuu set code=lpad(code,10,'0'), title=replace(title,'''','’');
update koatuu set title=replace(title,'М.','') where title like 'М.%';
update koatuu set title=upper('Масалаївка') where code='7424982503';
update koatuu set title=upper('Нечаївка') where code='5920982403';
update koatuu set title=upper('Тасуїв') where code='7420385004';
update koatuu set title=upper('Новомиколаївка') where code='5924780304';
update koatuu set title=upper('Баїха') where code='5920687002';
update koatuu set title=upper('Немудруї') where code='5923584404';
update koatuu set title=upper('Гаї-Смоленські') where code='4620381303';
update koatuu set title=upper('Межуївка') where code='1222983406';
update koatuu set title=upper('Мар’їне') where code='6521880803';
update koatuu set title=upper('Новоукраїнка') where code='5124786404';
update koatuu set title=upper('Миколаївка') where code='6524783505';
update koatuu set title=upper('Миколаївка') where code='5122384602';
update koatuu set title=upper('Аршиця') where code='7324587003';
update koatuu set title=upper('Мотина Балка') where code='1225286607';
update koatuu set title=upper('Заляддя') where code='7422487505';
update koatuu set title=upper('Тасуїв') where code='7420385004';
update koatuu set title=upper('Строїтель') where code='1424584608';
update koatuu set title=upper('Октябрське') where code='1421585601';
update koatuu set title=upper('Октябрське') where code='1421787002';
update koatuu set title=upper('Кузнеці') where code='1423686007';
update koatuu set title=upper('Дібрівка') where code='2124480404';
update koatuu set title=upper('Григорівка') where code='3520584502';
update koatuu set title=upper('Улянівка') where code='4412391005';
update koatuu set title=upper('Бистриця-Гірська') where code='4621280907';
update koatuu set title=upper('Гута Межиріцька') where code='7124984003';
update koatuu set title=upper('Плешкані') where code='7121588401';
update koatuu set title=upper('Мірошниківка') where code='7122583902';
update koatuu set title=upper('Глухів Другий') where code='1825085503';
update koatuu set title=upper('Мала Слобідка') where code='5921581502';
update koatuu set title=upper('Артюхове') where code='5922687206';
update koatuu set title=upper('Вовківка') where code='5921589303';
update koatuu set title=upper('Майдан-Копищенський') where code='1824484802';
delete from koatuu where code in ('2321186502','2321187401','2321188401');
update koatuu set title=upper('Велика Білозерка'), code='2321180101, 2321186502, 2321187401, 2321188401' where code='2321180101';
create index idx_koatuu_code on koatuu(code);

select '';
select 'Koatuu - missing place:';
select * 
from koatuu
where place<>'Р' 
  and code not in (select v from node_tags where k='koatuu' and node_id in (select node_id from node_tags where k='place' and v in ('city','town','village','hamlet')))
order by code;

select '';
select 'Koatuu - duplicated codes:';
select ntk.v,string_agg('n'||n.id,',' order by n.id)
from node_tags ntp
inner join nodes n on n.id=ntp.node_id
inner join node_tags ntk on ntk.node_id=n.id and ntk.k='koatuu'
where ntp.k='place' and ntp.v in ('city','town','village','hamlet')
group by ntk.v
having count(*)>1
order by ntk.v;
 
select '';
select 'Koatuu - different names:';
select n.id,ntk.v,code,ntn.v,title
from node_tags ntp
inner join nodes n on n.id=ntp.node_id
inner join regions r on st_contains(r.linestring, n.geom)
inner join node_tags ntn on ntn.node_id=n.id and ntn.k=(case when r.relation_id in (72639,1574364) then 'name:uk' else 'name' end)
left  join node_tags ntk on ntk.node_id=n.id and ntk.k='koatuu'
left  join koatuu k on k.code=ntk.v
where ntp.k='place' and ntp.v in ('city','town','village','hamlet')
  and coalesce(k.title,'')<>upper(ntn.v)
  and n.id not in (266318137,1326710031,337502296)
order by code,n.id;

select '';
select 'Koatuu - missing district';
select k.*,nt.node_id
from koatuu k
 left join node_tags nt on nt.k='koatuu' and nt.v=code
where coalesce(place,'М')='М' and code like '%00000' and code not like '%0000000'
  and code not in (select koatuu from districts)
order by k.code;

select '';
select 'Koatuu - missing city district';
select k.code,k.title,nt.node_id,ntn.v,rtn.relation_id,rtn.v,string_agg(rtq.relation_id::text,',' order by rtq.relation_id)
from koatuu k
 left join node_tags nt on nt.k='koatuu' and nt.v=substr(code,1,5)||'00000'
 left join node_tags ntn on ntn.node_id=nt.node_id and ntn.k='name'
 left join relation_tags rt on rt.v=code and rt.k='koatuu' and rt.relation_id in (select relation_id from relation_tags where k='admin_level' and v=(case when k.code like '8%' then '6' else '7' end))
 left join relation_tags rtn on rtn.relation_id=rt.relation_id and rtn.k='name'
 left join relation_tags rtq on rtq.k='name' and coalesce(upper(rtq.v),' ')=(k.title||' РАЙОН')
where place='Р'
 and coalesce(upper(rtn.v),' ')<>(k.title||' РАЙОН')
group by k.code,k.title,nt.node_id,ntn.v,rtn.relation_id,rtn.v
order by k.code;

select '';
select 'Koatuu - invalid code';
select relation_id, name,koatuu from districts where koatuu not in (select code from koatuu where coalesce(place,'М')='М' and code like '%00000' and code not like '%0000000');

select '';
select 'Koatuu - duplicated codes';
select koatuu,string_agg(relation_id::text,', '),string_agg(name,', ') from districts group by koatuu having count(*)>1;

select '';
select 'Koatuu - district overlap';
select 
d1.relation_id, d1.name, d2.relation_id, d2.name
from districts d1, districts d2
where _st_overlaps(d1.linestring, d2.linestring) and d1.relation_id<d2.relation_id;

select '';
select 'Koatuu - inconsistent codes for place and district';
select n.id,ntn.v,ntk.v,r.koatuu,r.name,r.relation_id
from node_tags ntp
inner join nodes n on n.id=ntp.node_id
inner join districts r on st_contains(r.linestring, n.geom)
inner join node_tags ntn on ntn.node_id=n.id and ntn.k='name'
inner join node_tags ntk on ntk.node_id=n.id and ntk.k='koatuu'
where ntp.k='place' and ntp.v in ('city','town','village','hamlet')
  and substr(ntk.v,1,5)<>substr(r.koatuu,1,5)
order by r.koatuu,ntk.v;