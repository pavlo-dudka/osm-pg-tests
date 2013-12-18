select rt.relation_id,count(distinct rmn.member_id),count(rmw.member_id),count(h.id),min(hb.id)
from relation_tags rt
left join relation_members rmn on rmn.member_role='via' and rmn.relation_id=rt.relation_id
left join relation_members rmw on rmw.member_role<>'via' and rmw.relation_id=rt.relation_id
left join highways h on h.id=rmw.member_id
left join highways hb on hb.id=rmw.member_id and hb.node0<>rmn.member_id and hb.node1<>rmn.member_id
where k='type' and v='restriction' 
group by rt.relation_id
having count(distinct rmn.member_id)<>1 or count(rmw.member_id)<>2 or count(h.id)<>2 or min(hb.id) is not null
order by 1;