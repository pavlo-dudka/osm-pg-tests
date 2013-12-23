select v,string_agg(way_id::text,',' order by way_id) 
from way_tags 
where k='name' and v like '% улица' and replace(v,' улица','') not in (select ru from streets) and replace(replace(v,' улица',''),' вулиця','') not in (select uk||' - '||ru from streets union select ru||' - '||uk from streets)
group by v
order by 1;