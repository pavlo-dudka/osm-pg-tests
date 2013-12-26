select 'name:';
select w.id,wt.v
from ways w
inner join way_tags wt on wt.way_id=w.id and wt.k in ('addr:housename','name')
where
(
 trim(wt.v)  similar to '[1-9][0-9\-]*[а-яєі]?(/[1-9][0-9]*[а-я]?)?( к[1-9][0-9]*)?' or         --trim it
lower(wt.v)  similar to '[1-9][0-9\-]*[а-яєі]?(/[1-9][0-9]*[а-я]?)?( к[1-9][0-9]*)?' or         --make it lower
       wt.v  similar to '[1-9][0-9\-]*[a-zA-Z]?(/[1-9][0-9]*[a-zA-Z]?)?' or                     --make it cyrilic
lower(wt.v)  similar to '[1-9][0-9\-]*[а-яєі]?(/[1-9][0-9]*[а-я]?)?( ?к\.? ?[1-9][0-9]*)?' or   --add space before "k", remove space after "k"
lower(wt.v)  similar to '[1-9][0-9\-]*[-/ ][а-яєі]' or                                          --remove "-/ " before character
       position('`' in wt.v)>0 or                                                               --remove "`"
       wt.v  in ('-','*','?','0','00'))
and not exists(select * from way_tags where way_id=w.id and  k not in ('name','addr:city','addr:housename','addr:housenumber','addr:street','addr:postcode','building','building:levels','building:material','source','height','nadoloni:id','source_ref') and v not in ('public_building'))
and not exists(select * from way_tags where way_id=w.id and (k     in ('addr:street') and v in ('Регенераторна вулиця') or k in ('highway','shop') or v in ('cafe','pub','restaurant')))
order by 1;

select '';
select 'addr:housenumber:';
select w.id,wt.v
from ways w
inner join way_tags wt on wt.way_id=w.id and wt.k='addr:housenumber'
where
       lower(wt.v) not similar to '([1-9][0-9]*-)*[1-9][0-9]*[а-яєі]?(/[1-9][0-9]*[а-я]?)?( к[1-9][0-9]*)?|бос [1-9][0-9]*' and
(
 trim(wt.v)  similar to '[1-9][0-9\-]*[а-яєі]?(/[1-9][0-9]*[а-я]?)?( к[1-9][0-9]*)?' or         --trim it
lower(wt.v)  similar to '[1-9][0-9\-]*[а-яєі]?(/[1-9][0-9]*[а-я]?)?( к[1-9][0-9]*)?' or         --make it lower
       wt.v  similar to '[1-9][0-9\-]*[a-zA-Z]?(/[1-9][0-9]*[a-zA-Z]?)?' or                     --make it cyrilic
lower(wt.v)  similar to '[1-9][0-9\-]*[а-яєі]?(/[1-9][0-9]*[а-я]?)?( ?к\.? ?[1-9][0-9]*)?' or   --add space before "k", remove space after "k"
lower(wt.v)  similar to '[1-9][0-9\-]*[-/ ][а-яєі]' or                                          --remove "-/ " before character
       position('`' in wt.v)>0 or                                                               --remove "`"
       wt.v  in ('-','*','?','0','00'))
order by 1;

select '';
select 'name:';
select w.id,wt.v
from nodes w
inner join node_tags wt on wt.node_id=w.id and wt.k in ('addr:housename','name')
where
(
 trim(wt.v)  similar to '[1-9][0-9\-]*[а-яєі]?(/[1-9][0-9]*[а-я]?)?( к[1-9][0-9]*)?' or         --trim it
lower(wt.v)  similar to '[1-9][0-9\-]*[а-яєі]?(/[1-9][0-9]*[а-я]?)?( к[1-9][0-9]*)?' or         --make it lower
       wt.v  similar to '[1-9][0-9\-]*[a-zA-Z]?(/[1-9][0-9]*[a-zA-Z]?)?' or                     --make it cyrilic
lower(wt.v)  similar to '[1-9][0-9\-]*[а-яєі]?(/[1-9][0-9]*[а-я]?)?( ?к\.? ?[1-9][0-9]*)?' or   --add space before "k", remove space after "k"
lower(wt.v)  similar to '[1-9][0-9\-]*[-/ ][а-яєі]' or                                          --remove "-/ " before character
       position('`' in wt.v)>0 or                                                               --remove "`"
       wt.v  in ('-','*','?','0','00')
)
and not exists(select * from node_tags where node_id=w.id and  k not in ('name','addr:city','addr:housename','addr:housenumber','addr:street','addr:postcode','building','building:levels','building:material','source','height','nadoloni:id','source_ref') and v not in ('public_building'))
and not exists(select * from node_tags where node_id=w.id and (k     in ('addr:street') and v in ('Регенераторна вулиця') or k in ('highway','shop') or v in ('cafe','pub','restaurant')))
order by 1;

select '';
select 'addr:housenumber:';
select w.id,wt.v
from nodes w
inner join node_tags wt on wt.node_id=w.id and wt.k='addr:housenumber'
where
       wt.v not similar to '[1-9][0-9\-]*[а-яєі]?(/[1-9][0-9]*[а-я]?)?( к[1-9][0-9]*)?|[1-9][0-9]*-[1-9][0-9]*|бос [1-9][0-9]*' and
(
 trim(wt.v)  similar to '[1-9][0-9\-]*[а-яєі]?(/[1-9][0-9]*[а-я]?)?( к[1-9][0-9]*)?' or         --trim it
lower(wt.v)  similar to '[1-9][0-9\-]*[а-яєі]?(/[1-9][0-9]*[а-я]?)?( к[1-9][0-9]*)?' or         --make it lower
       wt.v  similar to '[1-9][0-9\-]*[a-zA-Z]?(/[1-9][0-9]*[a-zA-Z]?)?' or                     --make it cyrilic
lower(wt.v)  similar to '[1-9][0-9\-]*[а-яєі]?(/[1-9][0-9]*[а-я]?)?( ?к\.? ?[1-9][0-9]*)?' or   --add space before "k", remove space after "k"
lower(wt.v)  similar to '[1-9][0-9\-]*[-/ ][а-яєі]' or                                          --remove "-/ " before character
       position('`' in wt.v)>0 or                                                               --remove "`"
       wt.v  in ('-','*','?','0','00'))
order by 1;