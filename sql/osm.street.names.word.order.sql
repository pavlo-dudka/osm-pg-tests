with tab as (
select wt.way_id, wt.k, wt.v, 
  trim(coalesce(p.prefix||' ','')||coalesce(t.title||' ','')||coalesce(n.name||' ','')||
	  regexp_replace(replace(replace(replace(wt.v||' ',coalesce(p.prefix||' ',''),''),coalesce(t.title||' ',''),''), coalesce(n.name||' ',''), ''), coalesce(w.reg||' ',''), ''))||
      coalesce(' '||w.type_f,'') as osm_name,
  trim(coalesce(w.type_f||' ','')||coalesce(p.prefix||' ','')||coalesce(t.title||' ','')||coalesce(n.name||' ','')||
	  regexp_replace(replace(replace(replace(wt.v||' ',coalesce(p.prefix||' ',''),''),coalesce(t.title||' ',''),''), coalesce(n.name||' ',''), ''), coalesce(w.reg||' ',''), '')) as osm_alt_name
from way_tags wt
  left join highways h on wt.way_id=h.id
  left join prefixes p on ' '||wt.v||' ' like '% '||p.prefix||' %'
  left join titles t on ' '||wt.v||' ' like '% '||t.title||' %'
  left join names n on ' '||wt.v||' ' like '% '||n.name||' %'
  left join way_type w on ' '||wt.v||' ' similar to '% '||w.reg||' %'
where not exists(select * from street_names_exc ex where wt.v like ex.name)
  and (h.id is null and wt.k='addr:street' or h.id is not null and wt.k in ('name','name:uk'))
  and wt.v not like 'улица %'
  and wt.v not like 'переулок %')
select way_id, k, v, osm_name from tab where v not in (osm_name, osm_alt_name)
order by 1, 2;

/*with tab as (
select wt.way_id, wt.k, wt.v, 
  	  trim(regexp_replace(replace(replace(replace(wt.v||' ',coalesce(p.prefix||' ',''),''),coalesce(t.title||' ',''),''), coalesce(n.name||' ',''), ''), coalesce(w.reg||' ',''), '')) as name
from way_tags wt
  inner join highways h on wt.way_id=h.id
  left join prefixes p on ' '||wt.v||' ' like '% '||p.prefix||' %'
  left join titles t on ' '||wt.v||' ' like '% '||t.title||' %'
  left join names n on ' '||wt.v||' ' like '% '||n.name||' %'
  left join way_type w on ' '||wt.v||' ' similar to '% '||w.reg||' %'
where not exists(select * from street_names_exc ex where wt.v like ex.name)
  and (h.id is not null and wt.k in ('name','name:uk'))
  and wt.v not like 'улица %'
  and wt.v not like 'переулок %')
select * from tab where name like '% %';*/