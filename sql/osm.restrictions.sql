select rt.relation_id,min(rmn.relation_id),count(*) 
from relation_tags rt
left  join relation_members rmn on rmn.member_role='via' and rmn.relation_id=rt.relation_id
inner join relation_members rmw on rmw.member_role<>'via' and rmw.relation_id=rt.relation_id
where k='type' and v='restriction' 
group by rt.relation_id
having count(*)<>2 or min(rmn.relation_id) is null;