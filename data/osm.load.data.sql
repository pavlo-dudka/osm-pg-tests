drop table if exists names;
create table names(name text);
copy names from 'osm/names.txt' using delimiters ',';

drop table if exists titles;
create table titles(title text);
copy titles from 'osm/titles.txt' using delimiters ',';

drop table if exists prefixes;
create table prefixes(prefix text);
copy prefixes from 'osm/prefixes.txt' using delimiters ',';

drop table if exists way_type;
create table way_type(lang text, type_f text, trans text, reg text);
copy way_type from 'osm/way_type.txt' using delimiters ',';
update way_type set lang=null where lang='';
update way_type set trans=null where trans='';
update way_type set reg=type_f where reg='';

drop table if exists highway_islands;
create table highway_islands(id int, highway_level text, location text);
copy highway_islands from 'osm/highway_islands.txt' using delimiters ',';

drop table if exists decommunization_names;
create table decommunization_names(name text);
copy decommunization_names from 'osm/decommunization.txt' using delimiters ',';