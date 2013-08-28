select 'api_key=24abcb162ae4b13639f58cdf4bb4c0729e11af70&q=truncate table ua_places_without_roads;';
--select 'api_key=24abcb162ae4b13639f58cdf4bb4c0729e11af70&q=';
select 'insert into ua_places_without_roads(osm_id,place,name,population,the_geom)';
select 'select '||id||','''||nt2.v||''','''||coalesce(replace(nt4.v,'''',''''''),'')||''','||coalesce(case when nt3.v similar to '[0-9]*' then nt3.v end,'0')||','''||geom::text||''' union '
    from node_tags nt
    inner join nodes on id=node_id
    inner join node_tags nt2 on nt2.node_id=id and nt2.k='place'
    left  join node_tags nt3 on nt3.node_id=id and nt3.k='population'
    left  join node_tags nt4 on nt4.node_id=id and nt4.k='name'
    where nt.k='temp-key';
select 'select 0,null,null,null,null where 0=1';