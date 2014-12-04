CREATE OR REPLACE FUNCTION CreateIslands(levels text[]) 
RETURNS void
AS $$
BEGIN
DECLARE	ind int;
	cnt int;
	arr int[];
	arr2 int[];
BEGIN
	insert into mainIsland
	with recursive tab as
	(
		select id from mainIsland
		union
		select id from highway_islands where highway_level=levels[1]
		union
		select h.id
		from tab 
		  inner join cross_way_nodes wn on wn.way_id_1 = tab.id
		  inner join highways h on h.id=wn.way_id_2
		where h.highway_level=any(levels)
	)
	select levels[1], 1 ind, id from tab;

	select array_agg(h.id::int) into arr
	from highways h
	where highway_level=any(levels)
	  and not exists(select * from mainIsland mi where mi.id=h.id)
	  and exists(select 1 from regions r where _st_contains(r.linestring, h.linestring));
	  
	cnt := 1;
	ind := 1;
	while (array_length(arr, 1)>0)
	loop
		ind := ind+1;

		with rows as (
			insert into mainIsland
			with recursive tab as (
				select min(id) id from unnest(arr) id
			union
				select wn.way_id_2::int
				from tab 
				  inner join cross_way_nodes wn on wn.way_id_1 = tab.id
				  inner join highways h on h.id=wn.way_id_2
				where h.highway_level=any(levels)
			)
			select levels[1], ind, id from tab where id is not null
			returning id
		) select array_agg(id) into arr2 from rows;

		arr := arr - arr2;
	end loop;
END;
END;
$$ LANGUAGE plpgsql;

drop table if exists mainIsland;
create table mainIsland(levels text, ind int, id bigint);
create index idx_mainIsland on mainIsland(id);
select CreateIslands(array['motorway','motorway_link']);
select CreateIslands(array['trunk','trunk_link']);
select CreateIslands(array['primary','primary_link']);
select CreateIslands(array['secondary','secondary_link']);
select CreateIslands(array['tertiary','tertiary_link']);
--select CreateIslands(array['unclassified','residential','living_street']);

select levels,ind,count(*),array_agg(id) from mainIsland group by levels,ind order by 3 desc;