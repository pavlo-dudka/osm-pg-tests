update way_tags
set v=trim(substr(v,7))||' вулиця'
where lower(v) like 'вулиця %'
and (k in ('name','name:uk') and way_id in (select way_id from way_tags where k='highway') or 
     k='addr:street' and way_id in (select way_id from way_tags where k='building'));

update way_tags
set v=trim(substr(v,5))||' вулиця'
where lower(v) like 'вул.%'
and (k in ('name','name:uk') and way_id in (select way_id from way_tags where k='highway') or 
     k='addr:street' and way_id in (select way_id from way_tags where k='building'));

update way_tags
set v=trim(substr(v,5))||' вулиця'
where lower(v) like 'вул %'
and (k in ('name','name:uk') and way_id in (select way_id from way_tags where k='highway') or 
     k='addr:street' and way_id in (select way_id from way_tags where k='building'));

update way_tags
set v=trim(substr(v,9))||' провулок'
where lower(v) like 'провулок %'
and (k in ('name','name:uk') and way_id in (select way_id from way_tags where k='highway') or 
     k='addr:street' and way_id in (select way_id from way_tags where k='building'));

update way_tags
set v=trim(substr(v,5))||' бульвар'
where lower(v) like 'бул.%'
and (k in ('name','name:uk','name:ru') and way_id in (select way_id from way_tags where k='highway') or 
     k='addr:street' and way_id in (select way_id from way_tags where k='building'));

update way_tags
set v=trim(substr(v,1,length(v)-4))||' вулиця'
where lower(v) similar to '% вул\.?'
and (k in ('name','name:uk') and way_id in (select way_id from way_tags where k='highway') or 
     k='addr:street' and way_id in (select way_id from way_tags where k='building'));

update way_tags
set v=trim(substr(v,1,length(v)-4))||' провулок'
where lower(v) similar to '% пров\.?'
and (k in ('name','name:uk') and way_id in (select way_id from way_tags where k='highway') or 
     k='addr:street' and way_id in (select way_id from way_tags where k='building'));

/*update way_tags
set v=v||' вулиця'
where v not similar to '% (шосе|дорога|узвіз|спуск)|(Н|н)абережная?'
  and exists(select * from streets s where uk=v)
  and k in ('name','name:uk') and way_id in (select way_id from way_tags where k='highway');

update way_tags
set v=v||' вулиця'
where v not similar to '% (шосе|дорога|узвіз|спуск)|(Н|н)абережная?'
  and exists(select * from streets s where uk=v)
  and k='addr:street' and way_id in (select way_id from way_tags where k='building');*/

update way_tags
set v=trim(substr(v,4))||' улица'
where lower(v) like 'ул.%'
and (k in ('name','name:ru') and way_id in (select way_id from way_tags where k='highway') or 
     k='addr:street' and way_id in (select way_id from way_tags where k='building'));

update way_tags
set v=trim(substr(v,4))||' улица'
where lower(v) like 'ул %'
and (k in ('name','name:ru') and way_id in (select way_id from way_tags where k='highway') or 
     k='addr:street' and way_id in (select way_id from way_tags where k='building'));

update way_tags
set v=trim(substr(v,6))||' улица'
where v like 'Улица %'
and (k in ('name','name:ru') and way_id in (select way_id from way_tags where k='highway') or 
     k='addr:street' and way_id in (select way_id from way_tags where k='building'));

update way_tags
set v=trim(substr(v,5))||' переулок'
where lower(v) like 'пер.%'
and (k in ('name','name:ru') and way_id in (select way_id from way_tags where k='highway') or 
     k='addr:street' and way_id in (select way_id from way_tags where k='building'));

update way_tags
set v=trim(substr(v,9))||' переулок'
where v like 'Переулок %'
and (k in ('name','name:ru') and way_id in (select way_id from way_tags where k='highway') or 
     k='addr:street' and way_id in (select way_id from way_tags where k='building'));

update way_tags
set v=trim(substr(v,1,length(v)-3))||' улица'
where lower(v) similar to '% ул\.?'
and (k in ('name','name:ru') and way_id in (select way_id from way_tags where k='highway') or 
     k='addr:street' and way_id in (select way_id from way_tags where k='building'));

update way_tags
set v=trim(substr(v,1,length(v)-4))||' переулок'
where lower(v) similar to '% пер\.?'
and (k in ('name','name:ru') and way_id in (select way_id from way_tags where k='highway') or 
     k='addr:street' and way_id in (select way_id from way_tags where k='building'));

/*update way_tags
set v=v||' улица'
where v not similar to '% (шоссе|дорога|спуск)|(Н|н)абережная?'
  and exists(select * from streets s where ru=v)
  and k in ('name','name:ru') and way_id in (select way_id from way_tags where k='highway');

update way_tags
set v=v||' улица'
where v not similar to '% (шоссе|дорога|спуск)|(Н|н)абережная?'
  and exists(select * from streets s where ru=v)
  and k='addr:street' and way_id in (select way_id from way_tags where k='building');*/