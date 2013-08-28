update cartodb set roads_date=null where roads_date is not null and user_id is null and exists(select * from nodes where id=node_id);
update cartodb u
    set user_id=t.user_id,roads_date=tstamp
from (
  select c.node_id,
        case when p.id is null then null else (select user_id from ways w where st_dwithin(p.geom,w.linestring,0.15) order by st_distance(w.linestring,p.geom) limit 1) end as user_id, 
        case when p.id is null then current_date else (select tstamp from ways w where st_dwithin(p.geom,w.linestring,0.15) order by st_distance(w.linestring,p.geom) limit 1) end as tstamp
  from cartodb c
    left join nodes p on p.id=c.node_id
    where roads_date is null and not exists(select * from node_tags nt where k='temp-key' and nt.node_id=c.node_id)) t
where u.node_id=t.node_id;
delete from cartodb where roads_date is not null and node_id in (select node_id from node_tags where k='temp-key');
insert into cartodb(node_id)
    select node_id from node_tags n where k='temp-key' and not exists(select * from cartodb c where c.node_id=n.node_id);