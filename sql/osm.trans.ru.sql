select v,string_agg(way_id::text,',' order by way_id) 
from way_tags, way_type
where k='name' and v like '% '||type_f and replace(v,' '||type_f,'') not in (select ru from streets) and replace(replace(v,' '||type_f,''),' '||trans,'') not in (select uk||' - '||ru from streets union select ru||' - '||uk from streets)
  and lang='ru'
group by v
order by 1;