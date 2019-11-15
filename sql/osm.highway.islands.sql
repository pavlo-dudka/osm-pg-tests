create extension if not exists intarray with schema public;

insert into cross_way_nodes
select way_id_2,way_id_1,null 
from cross_way_nodes
where not exists(select * from cross_way_nodes where way_id_1>way_id_2);


drop table if exists mainIsland;
create unlogged table mainIsland(highway_level text, ind int, id bigint) tablespace osmspace;
create index idx_mainIsland on mainIsland(id) tablespace osmspace;


CREATE OR REPLACE FUNCTION CreateIslands(VARIADIC levels text[]) 
RETURNS void
AS $$
BEGIN
DECLARE	ind int;
	arr int[];
	arr2 int[];
BEGIN
	insert into mainIsland
	select levels[1], 1, id from highway_islands where highway_level=any(levels);
	
	insert into mainIsland
	with recursive tab as
	(
		select 1 skip_flag, id from mainIsland
		union
		select 0 skip_flag, h.id
		from tab
		  inner join cross_way_nodes wn on tab.id = wn.way_id_1
		  inner join highways h on h.id=wn.way_id_2
		where h.highway_level=any(levels)
	)
	select levels[1], 1, id from tab
	where skip_flag=0;

	select array_agg(h.id::int order by h.id) into arr
	from highways h
	where highway_level=any(levels)
	  and not exists(select * from mainIsland mi where mi.id=h.id)
	  and exists(select 1 from regions r where _st_contains(r.linestring, h.linestring))
	  and st_npoints(h.linestring)>1;
	  
	ind := 1;
	while (array_length(arr, 1)>0)
	loop
		ind := ind + 1;

		with rows as (
			insert into mainIsland
			with recursive tab as (
				select highway_level, id::int from highways where id=arr[1]
			union
				select h.highway_level, wn.way_id_2::int
				from tab
				  inner join cross_way_nodes wn on tab.id = wn.way_id_1
				  inner join highways h on h.id=wn.way_id_2
				where h.highway_level=any(levels)
			)
			select highway_level, ind, id from tab
			returning id
		) select array_agg(id order by id) into arr2 from rows;

		arr := arr - arr2;
	end loop;
END;
END;
$$ LANGUAGE plpgsql;