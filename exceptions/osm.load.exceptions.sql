drop table if exists exc_street_relations_n;
create table exc_street_relations_n(street_relation_id_1 int, street_relation_id_2 int, comments text);
copy exc_street_relations_n from 'osm/street.relations.n.exc' using delimiters ',';

drop table if exists exc_street_relations_o;
create table exc_street_relations_o(street_relation_id int, place_relation_id int, comments text);
copy exc_street_relations_o from 'osm/street.relations.o.exc' using delimiters ',';