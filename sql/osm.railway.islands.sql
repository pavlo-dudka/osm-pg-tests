create extension if not exists intarray with schema public;

insert into cross_way_nodes_rail
select way_id_2,way_id_1,null 
from cross_way_nodes_rail
where not exists(select * from cross_way_nodes_rail where way_id_1>way_id_2);


drop table if exists mainIslandRail;
create table mainIslandRail(railway_level text, ind int, id bigint);
create index idx_mainIslandRail on mainIslandRail(id);


CREATE OR REPLACE FUNCTION CreateIslandsRail(VARIADIC levels text[]) 
RETURNS void
AS $$
BEGIN
DECLARE	ind int;
	arr int[];
	arr2 int[];
BEGIN
	insert into mainIslandRail
	select 'main', 1, 4429540;
	insert into mainIslandRail
	select 'main', 1, 26118465;
	insert into mainIslandRail
	select 'main', 1, 24946061;
	insert into mainIslandRail
        select 'main', 1, 211404007;
	insert into mainIslandRail
        select 'main', 1, 46668535;
	insert into mainIslandRail
        select 'main', 1, 92201760;	
	insert into mainIslandRail
        select 'main', 1, 33512752;
	insert into mainIslandRail

	with recursive tab as
	(
		select 1 skip, id from mainIslandRail
		union
		select 0 skip, h.id
		from tab
		  inner join cross_way_nodes_rail wn on tab.id = wn.way_id_1
		  inner join railways h on h.id=wn.way_id_2
		where h.railway_level=any(levels)
	)
	select levels[1], 1, id from tab
	where skip=0;

	select array_agg(h.id::int order by h.id) into arr
	from railways h
	where railway_level=any(levels)
	  and not exists(select * from mainIslandRail mi where mi.id=h.id)
	  and exists(select 1 from regions r where _st_contains(r.linestring, h.linestring))
	  and st_npoints(h.linestring)>1;
	  
	ind := 1;
	while (array_length(arr, 1)>0)
	loop
		ind := ind + 1;

		with rows as (
			insert into mainIslandRail
			with recursive tab as (
				select railway_level, id::int from railways where id=arr[1]
			union
				select h.railway_level, wn.way_id_2::int
				from tab
				  inner join cross_way_nodes_rail wn on tab.id = wn.way_id_1
				  inner join railways h on h.id=wn.way_id_2
				where h.railway_level=any(levels)
			)
			select railway_level, ind, id from tab
			returning id
		) select array_agg(id order by id) into arr2 from rows;

		arr := arr - arr2;
	end loop;
END;
END;
$$ LANGUAGE plpgsql;
