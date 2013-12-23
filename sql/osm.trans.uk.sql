select v,string_agg(way_id::text,',' order by way_id) 
from way_tags 
where k='name' and v like '% вулиця' and replace(v,' вулиця','') not in (select uk from streets) and replace(replace(v,' улица',''),' вулиця','') not in (select uk||' - '||ru from streets union select ru||' - '||uk from streets)
group by v
order by 1;