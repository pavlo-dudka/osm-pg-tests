select 'name:';
select w.id,wt.v
from ways w
inner join way_tags wt on wt.way_id=w.id and wt.k in ('addr:housename','name')
left  join way_tags wt2 on wt2.way_id=w.id and (wt2.k in ('amenity','shop','addr:street') and wt2.v in ('cafe','restaurant','bar','alcohol','convenience','Регенераторна вулиця'))
where
 wt2.k is null and (
 trim(wt.v)  similar to '[1-9][0-9\-]*[а-яєі]?(/[1-9][0-9]*[а-я]?)?( к[1-9][0-9]*)?' or         --trim it
lower(wt.v)  similar to '[1-9][0-9\-]*[а-яєі]?(/[1-9][0-9]*[а-я]?)?( к[1-9][0-9]*)?' or         --make it lower
       wt.v  similar to '[1-9][0-9\-]*[a-zA-Z]?(/[1-9][0-9]*[a-zA-Z]?)?' or                     --make it cyrilic
lower(wt.v)  similar to '[1-9][0-9\-]*[а-яєі]?(/[1-9][0-9]*[а-я]?)?( ?к\.? ?[1-9][0-9]*)?' or   --add space before "k", remove space after "k"
lower(wt.v)  similar to '[1-9][0-9\-]*[-/ ][а-яєі]' or                                          --remove "-/ " before character
       position('`' in wt.v)>0 or                                                               --remove "`"
       wt.v  in ('-','*','?','0','00'))
order by 1;

select '';
select 'addr:housenumber:';
select w.id,wt.v
from ways w
inner join way_tags wt on wt.way_id=w.id and wt.k='addr:housenumber'
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