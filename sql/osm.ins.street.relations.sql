insert into relations(id,version,user_id,tstamp,changeset_id)
select -min(w.id),1,440812,current_timestamp,0
from 
relations r 
inner join relation_tags rt on r.id=rt.relation_id and rt.k='name' and rt.v similar to 'Кривий Ріг'
inner join highways w on _st_intersects(r.linestring,w.linestring)
inner join way_tags wt on wt.way_id=w.id and wt.k in ('name','name:uk','name:ru')
--left  join way_tags wtu on wtu.way_id=w.id and wtu.k='name:uk'
--left  join way_tags wtr on wtr.way_id=w.id and wtr.k='name:ru'
where not exists(select * from relation_tags rt,relation_members rm where rt.relation_id=rm.relation_id and rt.k='type' and rt.v='associatedStreet' and rm.member_id=w.id and rm.member_type='W')
  and exists(select * from way_tags wt2, ways w2 where wt2.way_id=w2.id and wt2.k='addr:street' and wt2.v=wt.v and _st_dwithin(w.linestring,w2.linestring,0.01))
  --and not exists(select * from relation_tags rt1, relation_tags rt2 where rt1.relation_id=rt2.relation_id and rt1.k='type' and rt1.v='associatedStreet' and rt2.k='name' and rt2.v=wt.v)
  and wt.v similar to '% (вулиця|провулок|площа|проспект|бульвар|узвіз|міст|проїзд|набережна|шосе|алея|в’їзд|тупик|спуск|майдан|підйом|лінія|дорога|шляхопровід|автомагістраль|завулок|траса|улица|переулок|площадь|проспект|бульвар|спуск|мост|проезд|набережная|шоссе|аллея|въезд|тупик|спуск|майдан|подъём|линия|дорога|путепровод|автомагистраль|квартал|сквер|заезд|заулок|трасса|тоннель)'
group by wt.v;

insert into relation_members(relation_id,member_id,member_type,member_role,sequence_id)
select id,-id,'W','street',0
from relations
where id<0;

insert into relation_tags(relation_id,k,v)
select id,'type','associatedStreet'
from relations
where id<0;

insert into relation_tags(relation_id,k,v)
select id,k,v
from relations r
inner join way_tags wt on wt.way_id=-r.id and wt.k like 'name%'
where id<0;

delete from relation_tags where relation_id<0;
delete from relation_members where relation_id<0;
delete from relations where id<0;