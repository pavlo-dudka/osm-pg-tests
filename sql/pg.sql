--
-- PostgreSQL database dump
--

-- Dumped from database version 9.2.4
-- Dumped by pg_dump version 9.2.4
-- Started on 2013-12-18 16:37:31

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- TOC entry 7 (class 2615 OID 17509)
-- Name: topology; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA topology;


ALTER SCHEMA topology OWNER TO postgres;

--
-- TOC entry 199 (class 3079 OID 11727)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 3266 (class 0 OID 0)
-- Dependencies: 199
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- TOC entry 201 (class 3079 OID 672814392)
-- Name: fuzzystrmatch; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS fuzzystrmatch WITH SCHEMA public;


--
-- TOC entry 3267 (class 0 OID 0)
-- Dependencies: 201
-- Name: EXTENSION fuzzystrmatch; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION fuzzystrmatch IS 'determine similarities and distance between strings';


--
-- TOC entry 202 (class 3079 OID 252016)
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- TOC entry 3268 (class 0 OID 0)
-- Dependencies: 202
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- TOC entry 203 (class 3079 OID 16394)
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- TOC entry 3269 (class 0 OID 0)
-- Dependencies: 203
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry, geography, and raster spatial types and functions';


--
-- TOC entry 204 (class 3079 OID 17510)
-- Name: postgis_topology; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS postgis_topology WITH SCHEMA topology;


--
-- TOC entry 3270 (class 0 OID 0)
-- Dependencies: 204
-- Name: EXTENSION postgis_topology; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis_topology IS 'PostGIS topology spatial types and functions';


--
-- TOC entry 200 (class 3079 OID 678522617)
-- Name: xml2; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS xml2 WITH SCHEMA public;


--
-- TOC entry 3271 (class 0 OID 0)
-- Dependencies: 200
-- Name: EXTENSION xml2; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION xml2 IS 'XPath querying and XSLT';


SET search_path = public, pg_catalog;

--
-- TOC entry 1236 (class 1255 OID 678522557)
-- Name: bytea_import(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION bytea_import(p_path text, OUT p_result bytea) RETURNS bytea
    LANGUAGE plpgsql
    AS $$
declare
  l_oid oid;
  r record;
begin
  p_result := '';
  select lo_import(p_path) into l_oid;
  for r in ( select data 
             from pg_largeobject 
             where loid = l_oid 
             order by pageno ) loop
    p_result = p_result || r.data;
  end loop;
  perform lo_unlink(l_oid);
end;$$;


ALTER FUNCTION public.bytea_import(p_path text, OUT p_result bytea) OWNER TO postgres;

--
-- TOC entry 1198 (class 1255 OID 17732)
-- Name: osmosisupdate(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION osmosisupdate() RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
END;
$$;


ALTER FUNCTION public.osmosisupdate() OWNER TO postgres;

--
-- TOC entry 1235 (class 1255 OID 678522556)
-- Name: xml_import(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION xml_import(filename text) RETURNS xml
    LANGUAGE plpgsql
    AS $$
    declare
        content bytea;
        loid oid;
        lfd integer;
        lsize integer;
    begin
        loid := lo_import(filename);
        lfd := lo_open(loid,262144);
        lsize := lo_lseek(lfd,0,2);
        perform lo_lseek(lfd,0,0);
        content := loread(lfd,lsize);
        perform lo_close(lfd);
        perform lo_unlink(loid);
 
        return xmlparse(document convert_from(content,'UTF8'));
    end;
$$;


ALTER FUNCTION public.xml_import(filename text) OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 191 (class 1259 OID 17680)
-- Name: node_tags; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE node_tags (
    node_id bigint NOT NULL,
    k text NOT NULL,
    v text NOT NULL
);


ALTER TABLE public.node_tags OWNER TO postgres;

--
-- TOC entry 190 (class 1259 OID 17674)
-- Name: nodes; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE nodes (
    id bigint NOT NULL,
    version integer NOT NULL,
    user_id integer NOT NULL,
    tstamp timestamp with time zone NOT NULL,
    changeset_id bigint NOT NULL,
    geom geometry(Point,4326)
);


ALTER TABLE public.nodes OWNER TO postgres;

--
-- TOC entry 196 (class 1259 OID 17701)
-- Name: relation_members; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE relation_members (
    relation_id bigint NOT NULL,
    member_id bigint NOT NULL,
    member_type character(1) NOT NULL,
    member_role text NOT NULL,
    sequence_id integer NOT NULL
);


ALTER TABLE public.relation_members OWNER TO postgres;

--
-- TOC entry 197 (class 1259 OID 17707)
-- Name: relation_tags; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE relation_tags (
    relation_id bigint NOT NULL,
    k text NOT NULL,
    v text NOT NULL
);


ALTER TABLE public.relation_tags OWNER TO postgres;

--
-- TOC entry 195 (class 1259 OID 17698)
-- Name: relations; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE relations (
    id bigint NOT NULL,
    version integer NOT NULL,
    user_id integer NOT NULL,
    tstamp timestamp with time zone NOT NULL,
    changeset_id bigint NOT NULL,
    linestring geometry(Geometry,4326)
);


ALTER TABLE public.relations OWNER TO postgres;


SET default_with_oids = false;

--
-- TOC entry 188 (class 1259 OID 17665)
-- Name: schema_info; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE schema_info (
    version integer NOT NULL
);


ALTER TABLE public.schema_info OWNER TO postgres;

--
-- TOC entry 189 (class 1259 OID 17668)
-- Name: users; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    name text NOT NULL
);


ALTER TABLE public.users OWNER TO postgres;

--
-- TOC entry 193 (class 1259 OID 17689)
-- Name: way_nodes; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE way_nodes (
    way_id bigint NOT NULL,
    node_id bigint NOT NULL,
    sequence_id integer NOT NULL
);


ALTER TABLE public.way_nodes OWNER TO postgres;

SET default_with_oids = true;

--
-- TOC entry 194 (class 1259 OID 17692)
-- Name: way_tags; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE way_tags (
    way_id bigint NOT NULL,
    k text NOT NULL,
    v text
);


ALTER TABLE public.way_tags OWNER TO postgres;

SET default_with_oids = false;

--
-- TOC entry 192 (class 1259 OID 17686)
-- Name: ways; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE ways (
    id bigint NOT NULL,
    version integer NOT NULL,
    user_id integer NOT NULL,
    tstamp timestamp with time zone NOT NULL,
    changeset_id bigint NOT NULL,
    linestring geometry(Geometry,4326),
    bbox geometry(Geometry,4326)
);


ALTER TABLE public.ways OWNER TO postgres;

--
-- TOC entry 3251 (class 0 OID 17680)
-- Dependencies: 191
-- Data for Name: node_tags; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY node_tags (node_id, k, v) FROM stdin;
\.


--
-- TOC entry 3250 (class 0 OID 17674)
-- Dependencies: 190
-- Data for Name: nodes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY nodes (id, version, user_id, tstamp, changeset_id, geom) FROM stdin;
\.


--
-- TOC entry 3256 (class 0 OID 17701)
-- Dependencies: 196
-- Data for Name: relation_members; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY relation_members (relation_id, member_id, member_type, member_role, sequence_id) FROM stdin;
\.


--
-- TOC entry 3257 (class 0 OID 17707)
-- Dependencies: 197
-- Data for Name: relation_tags; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY relation_tags (relation_id, k, v) FROM stdin;
\.


--
-- TOC entry 3255 (class 0 OID 17698)
-- Dependencies: 195
-- Data for Name: relations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY relations (id, version, user_id, tstamp, changeset_id, linestring) FROM stdin;
\.

--
-- TOC entry 3248 (class 0 OID 17665)
-- Dependencies: 188
-- Data for Name: schema_info; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY schema_info (version) FROM stdin;
5
\.


--
-- TOC entry 3217 (class 0 OID 16634)
-- Dependencies: 170
-- Data for Name: spatial_ref_sys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY spatial_ref_sys (srid, auth_name, auth_srid, srtext, proj4text) FROM stdin;
\.


--
-- TOC entry 3249 (class 0 OID 17668)
-- Dependencies: 189
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY users (id, name) FROM stdin;
\.


--
-- TOC entry 3253 (class 0 OID 17689)
-- Dependencies: 193
-- Data for Name: way_nodes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY way_nodes (way_id, node_id, sequence_id) FROM stdin;
\.


--
-- TOC entry 3254 (class 0 OID 17692)
-- Dependencies: 194
-- Data for Name: way_tags; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY way_tags (way_id, k, v) FROM stdin;
\.


--
-- TOC entry 3252 (class 0 OID 17686)
-- Dependencies: 192
-- Data for Name: ways; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY ways (id, version, user_id, tstamp, changeset_id, linestring, bbox) FROM stdin;
\.


SET search_path = topology, pg_catalog;

--
-- TOC entry 3219 (class 0 OID 17526)
-- Dependencies: 184
-- Data for Name: layer; Type: TABLE DATA; Schema: topology; Owner: postgres
--

COPY layer (topology_id, layer_id, schema_name, table_name, feature_column, feature_type, level, child_id) FROM stdin;
\.


--
-- TOC entry 3218 (class 0 OID 17513)
-- Dependencies: 183
-- Data for Name: topology; Type: TABLE DATA; Schema: topology; Owner: postgres
--

COPY topology (id, name, srid, "precision", hasz) FROM stdin;
\.


SET search_path = public, pg_catalog;

--
-- TOC entry 3230 (class 2606 OID 697583652)
-- Name: pk_nodes; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY nodes
    ADD CONSTRAINT pk_nodes PRIMARY KEY (id);


--
-- TOC entry 3246 (class 2606 OID 697583660)
-- Name: pk_relation_members; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY relation_members
    ADD CONSTRAINT pk_relation_members PRIMARY KEY (relation_id, sequence_id);


--
-- TOC entry 3244 (class 2606 OID 697583658)
-- Name: pk_relations; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY relations
    ADD CONSTRAINT pk_relations PRIMARY KEY (id);


--
-- TOC entry 3225 (class 2606 OID 17714)
-- Name: pk_schema_info; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY schema_info
    ADD CONSTRAINT pk_schema_info PRIMARY KEY (version);


--
-- TOC entry 3227 (class 2606 OID 697583650)
-- Name: pk_users; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT pk_users PRIMARY KEY (id);


--
-- TOC entry 3240 (class 2606 OID 697583656)
-- Name: pk_way_nodes; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY way_nodes
    ADD CONSTRAINT pk_way_nodes PRIMARY KEY (way_id, sequence_id);


--
-- TOC entry 3235 (class 2606 OID 697583654)
-- Name: pk_ways; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY ways
    ADD CONSTRAINT pk_ways PRIMARY KEY (id);


--
-- TOC entry 3231 (class 1259 OID 697583661)
-- Name: idx_node_tags_node_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX idx_node_tags_node_id ON node_tags USING btree (node_id);


--
-- TOC entry 3228 (class 1259 OID 697583662)
-- Name: idx_nodes_geom; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX idx_nodes_geom ON nodes USING gist (geom);


--
-- TOC entry 3247 (class 1259 OID 697583664)
-- Name: idx_relation_tags_relation_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX idx_relation_tags_relation_id ON relation_tags USING btree (relation_id);


--
-- TOC entry 3242 (class 1259 OID 27644)
-- Name: idx_relations_linestring; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX idx_relations_linestring ON relations USING gist (linestring);


--
-- TOC entry 3236 (class 1259 OID 697583665)
-- Name: idx_way_nodes_node_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX idx_way_nodes_node_id ON way_nodes USING btree (node_id);


--
-- TOC entry 3237 (class 1259 OID 18621)
-- Name: idx_way_nodes_way_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX idx_way_nodes_way_id ON way_nodes USING btree (way_id);


--
-- TOC entry 3238 (class 1259 OID 186585)
-- Name: idx_way_nodes_way_id_seq_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX idx_way_nodes_way_id_seq_id ON way_nodes USING btree (way_id, sequence_id);


--
-- TOC entry 3241 (class 1259 OID 697583663)
-- Name: idx_way_tags_way_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX idx_way_tags_way_id ON way_tags USING btree (way_id);


--
-- TOC entry 3232 (class 1259 OID 697583666)
-- Name: idx_ways_bbox; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX idx_ways_bbox ON ways USING gist (bbox);


--
-- TOC entry 3233 (class 1259 OID 697584119)
-- Name: idx_ways_linestring; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX idx_ways_linestring ON ways USING gist (linestring);


--
-- TOC entry 3214 (class 2618 OID 17051)
-- Name: geometry_columns_delete; Type: RULE; Schema: public; Owner: postgres
--

CREATE RULE geometry_columns_delete AS ON DELETE TO geometry_columns DO INSTEAD NOTHING;


--
-- TOC entry 3212 (class 2618 OID 17049)
-- Name: geometry_columns_insert; Type: RULE; Schema: public; Owner: postgres
--

CREATE RULE geometry_columns_insert AS ON INSERT TO geometry_columns DO INSTEAD NOTHING;


--
-- TOC entry 3213 (class 2618 OID 17050)
-- Name: geometry_columns_update; Type: RULE; Schema: public; Owner: postgres
--

CREATE RULE geometry_columns_update AS ON UPDATE TO geometry_columns DO INSTEAD NOTHING;


--
-- TOC entry 3265 (class 0 OID 0)
-- Dependencies: 5
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2013-12-18 16:37:32

--
-- PostgreSQL database dump complete
--

