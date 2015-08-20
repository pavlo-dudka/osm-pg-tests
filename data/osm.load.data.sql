drop table if exists names;
create table names(name text);
copy names from 'osm/names.txt' with delimiter ',';

drop table if exists titles;
create table titles(title text);
copy titles from 'osm/titles.txt' with delimiter ',';

drop table if exists prefixes;
create table prefixes(prefix text);
copy prefixes from 'osm/prefixes.txt' with delimiter ',';

drop table if exists way_type;
create table way_type(lang text, type_f text, trans text, reg text);
copy way_type from 'osm/way_type.txt' with delimiter ',';
update way_type set lang=null where lang='';
update way_type set trans=null where trans='';
update way_type set reg=type_f where reg='';

drop table if exists highway_islands;
create table highway_islands(id int, highway_level text, location text);
copy highway_islands from 'osm/highway_islands.txt' with delimiter ',';
