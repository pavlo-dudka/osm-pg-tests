with streets1 as (
  select string_agg(distinct 'w'||way_id::text, ',' order by 'w'||way_id::text) objs, v street
  from way_tags ot 
    left join highways h on ot.way_id=h.id 
  where not exists(select * from street_names_exc ex where ot.v like ex.name)
    and (h.id is null and ot.k='addr:street' or h.id is not null and ot.k in ('name','name:uk','old_name','old_name:uk'))
  group by v
 union
  select string_agg(distinct 'n'||node_id::text, ',' order by 'n'||node_id::text) objs, v street
  from node_tags ot 
  where not exists(select * from street_names_exc ex where ot.v like ex.name)
    and ot.k='addr:street'
  group by v
 union
  select string_agg(distinct 'r'||relation_id::text, ',' order by 'r'||relation_id::text) objs, v street
  from relation_tags ot 
  where not exists(select * from street_names_exc ex where ot.v like ex.name)
    and ot.k='addr:street'
  group by v),
streets2 as (
  select string_agg(objs, ',' order by objs), street
  from streets1
  group by street
),
streets3 as (
  select a.objs,a.street,p.prefix,t.title,n.name,w.type_f,
     trim(regexp_replace(replace(regexp_replace(replace(a.street||' ',coalesce(p.prefix||' ',''),''),coalesce(t.title||' ',''),'','i'), coalesce(n.name||' ',''), ''), coalesce(w.reg||' ',type_f||' ',''), '')) as base
  from streets1 a
    left join prefixes p on ' '||a.street||' ' like '% '||p.prefix||' %'
    left join titles t on ' '||a.street||' ' ilike '% '||t.title||' %'
    left join names n on ' '||a.street||' ' like '% '||n.name||' %'
    left join way_type w on ' '||a.street||' ' similar to '% '||coalesce(w.reg,type_f)||' %'
),
streets4 as (
  select objs, street,
    trim(coalesce(prefix||' ','')||coalesce(title||' ','')||coalesce(name||' ','')||base)||coalesce(' '||type_f,'') as osm_name,
    trim(coalesce(type_f||' ','')||coalesce(prefix||' ','')||coalesce(title||' ','')||coalesce(name||' ','')||base) as osm_alt_name,
    base
  from streets3
)
select street,osm_name,string_agg(objs,',' order by objs)
from streets4
where street not in (osm_name, osm_alt_name)
group by 1,2
order by 1,2;