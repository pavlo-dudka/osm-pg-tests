select 'Ways';
select v,k,string_agg(way_id::text, ',' order by way_id) 
from way_tags 
where k like '%ref' and v similar to '[HPTOC]%|M[ -]%|Т[ -]?[0-9][0-9][ -]?[0-9][0-9]| %|% ' and v not similar to 'Т-[0-9][0-9]-[0-9][0-9]' 
group by v,k
order by 1;

select '';
select 'Relations';
select v,k,string_agg(relation_id::text, ',' order by relation_id) 
from relation_tags 
where k like '%ref' and v similar to '[HPTOC]%|M[ -]%|Т[ -]?[0-9][0-9][ -]?[0-9][0-9]| %|% ' and v not similar to 'Т-[0-9][0-9]-[0-9][0-9]' 
and relation_id not in (915305)
group by v,k
order by 1;

select '';
select 'Relation name';
select * from relation_tags rt 
inner join relation_tags rt2 on rt2.relation_id=rt.relation_id and rt2.k='name' and rt2.v<>('Автошлях '||rt.v)
where rt.k='ref' and rt.v similar to 'Т-__-__|М-__|Н-__|Р-__|О%|С%';

select '';
select 'Relation wikipedia';
select * from relation_tags rt 
inner join relation_tags rtw on rtw.relation_id=rt.relation_id and rtw.k='wikipedia' and rtw.v<>('uk:Автошлях_'||substr(rt.v,1,1)||'_'||replace(substr(rt.v,2),'-',''))
where rt.k='ref' and rt.v similar to 'Т-__-__|М-__|Н-__|Р-__|О%|С%';