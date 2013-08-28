select n.id,ntn.v
from regions 
inner join nodes n on st_contains(linestring,n.geom)
inner join node_tags ntp on ntp.node_id=n.id and ntp.k='place' and ntp.v in ('village','hamlet')
left join node_tags ntn on ntn.node_id=n.id and ntn.k='name'
where name='Севастополь'
order by 2;