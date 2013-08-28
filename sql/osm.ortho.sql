with tab as (
select 
id,
st_distance((select geom from nodes where id=nodes[1]), (select geom from nodes where id=nodes[3])) d1,
st_distance((select geom from nodes where id=nodes[2]), (select geom from nodes where id=nodes[4])) d2,
nodes
from ways 
where tags ? 'building' 
and nodes[1] = nodes[array_length(nodes, 1)]
and array_length(nodes, 1)=5
)
select id, d1, d2, greatest(d1/d2,d2/d1), nodes
from tab
where greatest(d1/d2,d2/d1) between 1.05 and 1.25
order by 4 desc
limit 100