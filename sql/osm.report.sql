drop table if exists places;
create table places as
select n.id,n.geom from nodes n
inner join node_tags nt on nt.node_id=n.id and nt.k='place' and nt.v in ('city','town','village','hamlet');

create index idx_places_geom on places using gist(geom);

select 'Validation started at: '||max(tstamp) from nodes;
with t as (
 select name,'500m'::text as d,
 (select count(*) from places n where st_within(geom,r.linestring)='t') c1,
 (select count(*) from places n where st_within(geom,r.linestring)='t' and not exists(select * from node_tags where node_id=n.id and k='temp-key')) c2
 from relations r inner join regions on id=relation_id
),
t2 as 
(select name,d,c2,c1,case when c1=0 then '0' else 100*c2/c1 end p,1 from t 
 union
 select 'Total',null d,sum(c2),sum(c1),floor(100*sum(c2)/sum(c1)),2 from t 
 order by 6,5 desc,1
)
select name,d,c2,c1,p||'%' from t2;
select roads_date,coalesce(name,'- -'),c.node_id,coalesce(v,case when n.id is null then 'PLACE REMOVED' else 'NO NAME' end),
(select rt2.v from relations r inner join relation_tags on id=relation_id and k='admin_level' and v='4' inner join relation_tags rt2 on id=rt2.relation_id and rt2.k='name' where st_within(n.geom,r.linestring)),
(select rt2.v from relations r inner join relation_tags on id=relation_id and k='admin_level' and v='6' inner join relation_tags rt2 on id=rt2.relation_id and rt2.k='name' where st_within(n.geom,r.linestring))
from cartodb c
left join users on user_id=id
left join node_tags nt on k='name' and nt.node_id=c.node_id
left join nodes n on n.id=c.node_id
where roads_date > (current_date - interval '7 days')
order by roads_date desc;