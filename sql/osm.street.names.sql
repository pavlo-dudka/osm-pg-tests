select r.name,wt.k,wt.v,string_agg(wt.way_id::text,',' order by wt.way_id)
from highways h
inner join regions r on st_intersects(r.linestring,h.linestring)
inner join way_tags wt on wt.way_id=h.id and wt.k in ('name','name:uk','name:ru')
where 
(wt.k='name:uk' or wt.k='name' and r.relation_id not in (72639,71973,71971,1574364))
and wt.v not similar to '[А-Я][а-яєії]* вулиця, [0-9]*-й (провулок|проїзд|тупик)'
and not exists(select * from way_type where wt.v similar to '([АаБбВвГгҐґДдЕеЄєЖжЗзиІіїЇЙйКкЛлМмНнОоПпРрСсТтУуФфХхЦцЧчШшЩщьЮюЯя0-9XVI’«»"''\- \.]+)'||type_f and coalesce(lang,'uk')='uk')
and not exists(select * from way_type where wt.v similar to type_f||'([АаБбВвГгҐґДдЕеЄєЖжЗзиІіїЇЙйКкЛлМмНнОоПпРрСсТтУуФфХхЦцЧчШшЩщьЮюЯя0-9XVI’«»"''\- \.]+)' and coalesce(lang,'uk')='uk')
or
wt.k='name:ru'
and wt.v not similar to '[А-Я][а-яё]* улица, [0-9]*-й (переулок|проезд|тупик)'
and not exists(select * from way_type where wt.v similar to '([АаБбВвГгДдЕеЁёЖжЗзИиЙйКкЛлМмНнОоПпРрСсТтУуФфХхЦцЧчШшЩщъыьЭэЮюЯя0-9XVI«»"\- \.]+)'||type_f and coalesce(lang,'ru')='ru')  
and not exists(select * from way_type where wt.v similar to type_f||'([АаБбВвГгДдЕеЁёЖжЗзИиЙйКкЛлМмНнОоПпРрСсТтУуФфХхЦцЧчШшЩщъыьЭэЮюЯя0-9XVI«»"\- \.]+)' and coalesce(lang,'ru')='ru')  
or 
wt.k='name' and r.relation_id in (72639,71973,71971,1574364)
and wt.v not similar to '[А-Я][а-яєії]* вулиця, [0-9]*-й (провулок|проїзд|тупик)'
and wt.v not similar to '[А-Я][а-яё]* улица, [0-9]*-й (переулок|проезд|тупик)'
and not exists(select * from way_type where wt.v similar to '([АаБбВвГгҐґДдЕеЄєЖжЗзиІіїЇЙйКкЛлМмНнОоПпРрСсТтУуФфХхЦцЧчШшЩщьЮюЯя0-9XVI’«»"''\- \.]+)'||type_f and coalesce(lang,'uk')='uk')
and not exists(select * from way_type where wt.v similar to type_f||'([АаБбВвГгҐґДдЕеЄєЖжЗзиІіїЇЙйКкЛлМмНнОоПпРрСсТтУуФфХхЦцЧчШшЩщьЮюЯя0-9XVI’«»"''\- \.]+)' and coalesce(lang,'uk')='uk')
and not exists(select * from way_type where wt.v similar to '([АаБбВвГгДдЕеЁёЖжЗзИиЙйКкЛлМмНнОоПпРрСсТтУуФфХхЦцЧчШшЩщъыьЭэЮюЯя0-9XVI«»"\- \.]+)'||type_f and coalesce(lang,'ru')='ru')  
and not exists(select * from way_type where wt.v similar to type_f||'([АаБбВвГгДдЕеЁёЖжЗзИиЙйКкЛлМмНнОоПпРрСсТтУуФфХхЦцЧчШшЩщъыьЭэЮюЯя0-9XVI«»"\- \.]+)' and coalesce(lang,'ru')='ru')  
group by r.name,wt.k,wt.v
order by r.name,wt.k,wt.v;

select r.name,wt.k,wt.v,string_agg(wt.way_id::text,',' order by wt.way_id)
from ways h
inner join regions r on st_intersects(r.linestring,h.linestring)
inner join way_tags wt on wt.way_id=h.id and wt.k in ('addr:street')
where 
r.relation_id not in (72639,71973,71971,1574364)
and wt.v not similar to '[А-Я][а-яєії]* вулиця, [0-9]*-й (провулок|проїзд|тупик)'
and not exists(select * from way_type where wt.v similar to '([АаБбВвГгҐґДдЕеЄєЖжЗзиІіїЇЙйКкЛлМмНнОоПпРрСсТтУуФфХхЦцЧчШшЩщьЮюЯя0-9XVI’«»"''\- \.]+)'||type_f and coalesce(lang,'uk')='uk')
and not exists(select * from way_type where wt.v similar to type_f||'([АаБбВвГгҐґДдЕеЄєЖжЗзиІіїЇЙйКкЛлМмНнОоПпРрСсТтУуФфХхЦцЧчШшЩщьЮюЯя0-9XVI’«»"''\- \.]+)' and coalesce(lang,'uk')='uk')
or 
r.relation_id in (72639,71973,71971,1574364)
and wt.v not similar to '[А-Я][а-яєії]* вулиця, [0-9]*-й (провулок|проїзд|тупик)'
and wt.v not similar to '[А-Я][а-яё]* улица, [0-9]*-й (переулок|проезд|тупик)'
and not exists(select * from way_type where wt.v similar to '([АаБбВвГгҐґДдЕеЄєЖжЗзиІіїЇЙйКкЛлМмНнОоПпРрСсТтУуФфХхЦцЧчШшЩщьЮюЯя0-9XVI’«»"''\- \.]+)'||type_f and coalesce(lang,'uk')='uk')
and not exists(select * from way_type where wt.v similar to type_f||'([АаБбВвГгҐґДдЕеЄєЖжЗзиІіїЇЙйКкЛлМмНнОоПпРрСсТтУуФфХхЦцЧчШшЩщьЮюЯя0-9XVI’«»"''\- \.]+)' and coalesce(lang,'uk')='uk')
and not exists(select * from way_type where wt.v similar to '([АаБбВвГгДдЕеЁёЖжЗзИиЙйКкЛлМмНнОоПпРрСсТтУуФфХхЦцЧчШшЩщъыьЭэЮюЯя0-9XVI«»"\- \.]+)'||type_f and coalesce(lang,'ru')='ru')  
and not exists(select * from way_type where wt.v similar to type_f||'([АаБбВвГгДдЕеЁёЖжЗзИиЙйКкЛлМмНнОоПпРрСсТтУуФфХхЦцЧчШшЩщъыьЭэЮюЯя0-9XVI«»"\- \.]+)' and coalesce(lang,'ru')='ru')  
group by r.name,wt.k,wt.v
order by r.name,wt.k,wt.v;