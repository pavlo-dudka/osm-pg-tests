set client_min_messages to warning;
drop table if exists end_nodes;
create unlogged table end_nodes tablespace osmspace as
select h.layer,h.id as way_id,n.geom,n.id
from highways h
inner join nodes n on n.id in (h.node0, h.node1)
where (select count(*) from way_nodes wn2,highways h2 where wn2.node_id=n.id and wn2.way_id=h2.id)=1
  and not exists(select * from node_tags nt where nt.node_id=n.id and nt.k='noexit' and nt.v in ('yes','true','1'))
  and not exists(select * from node_tags nt where nt.node_id=n.id and nt.k='amenity' and nt.v in ('parking_entrance')) 	
  and not exists(select * from node_tags nt where nt.node_id=n.id and nt.k='highway' and nt.v='turning_circle')
  and not exists(select * from way_tags wt where wt.way_id=h.id and wt.k='highway' and wt.v in ('platform','track','steps'))
  and n.id not in (546405082,546351032,2324552116,1791825888,1616608260,1059524279,1452513637,1452513638,1822002730,1822002733,2394431921,2425800793,1467562604,2592172507,2101228907,2689723398,2829656039,2829656040,2837572323,2837572324,2873642931,2873644569,2394352673,3203890898,3048094345,3284065779,3048996881,1596087928,1985089917,3629898598,2860201986,2415862109,2481775890,2491398856,3258098260,4006986276,4006986277,4035509811,4069702751,3801889377,4373919773,4364483434,3016440446,1748336352,3207992899,2326287101,5026619703,4608657998,5026619676,4608668380,5026619675,5026619690,5026619691,5077657516,4944025896,3481684854,3746420910,4894341834,4894341835,4972576998,5981666603,5981666604,5981666601,5981666602,5113200847,5787502965,5787502966,5872278174,5938726968,5955223675,3662182599)
  and h.node0<>h.node1;
create index idx_end_nodes_geom on end_nodes using gist(geom) tablespace osmspace;

select '{';
select '"type": "FeatureCollection",';
select '"errorDescr": "End-node is located close to another way",';
select '"features": [';
select '{"type":"Feature","id":"'||b.id||'","properties":{"josm":"n'||b.id||','||string_agg('w'||t.id,',' order by t.id)||'"},"geometry":'||st_asgeojson(b.geom,5)||'},'
from highways t
inner join end_nodes b on st_dwithin(t.linestring,b.geom,0.01) and t.id<>b.way_id and t.layer=b.layer and st_dwithin(b.geom::geography, t.linestring::geography, (case when t.highway_level='service' then 2 else 5 end))
 left join highways h on h.id=b.way_id 
where (_st_intersects(h.linestring,t.linestring)='f'
  or not st_dwithin(b.geom::geography, st_intersection(h.linestring,t.linestring)::geography, 5))
  and t.highway_level not in ('platform','track','steps')
group by b.id,b.geom
order by b.id;

select '{"type":"Feature"}';
select ']}';
