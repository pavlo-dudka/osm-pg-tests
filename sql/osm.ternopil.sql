select 'Different wiki-tags:';
select rt2.relation_id from relations r
inner join relation_tags rt on relation_id=id and k='koatuu' and v like '61%'
inner join relation_tags rt2 on rt2.relation_id=id and rt2.k='name'
inner join relation_tags rt3 on rt3.relation_id=id and rt3.k='wikipedia'
where id>3166623
and exists(select * from relation_tags,nodes n,node_tags nt where relation_id=r.id and n.id=node_id and nt.k='name' and nt.v=rt2.v and st_contains(linestring,geom))
and not exists(select * from relation_tags,nodes n,node_tags nt where relation_id=r.id and n.id=node_id and nt.k='wikipedia' and nt.v=rt3.v and st_contains(linestring,geom));

select '';
select 'Place node not found:';
select rt2.relation_id from relations r
inner join relation_tags on relation_id=id and k='koatuu' and v like '61%'
inner join relation_tags rt2 on rt2.relation_id=id and rt2.k='name'
where id>3166623 and
not exists(select * from relation_tags,nodes n,node_tags nt where relation_id=r.id and n.id=node_id and nt.k='name' and nt.v=rt2.v and st_contains(linestring,geom))
order by 1;

select '';
select 'Boundary crosses admin_level=6:';
--Ternopil
select r.id from relations r
inner join relation_tags rt on relation_id=id and k='koatuu' and v like '61%' 
inner join relation_tags rt1 on rt1.k='admin_level' and rt1.v='8' and rt1.relation_id=r.id
inner join relation_tags rt2 on rt2.k='admin_level' and rt2.v='6'
inner join relation_tags rt3 on rt3.k='koatuu' and rt3.v like '61%' and rt3.relation_id=rt2.relation_id
inner join relations r2 on r2.id=rt2.relation_id and r2.linestring is not null and st_isvalid(r.linestring) and st_overlaps(r.linestring,r2.linestring)
group by r.id
having count(*)>1
order by 1;