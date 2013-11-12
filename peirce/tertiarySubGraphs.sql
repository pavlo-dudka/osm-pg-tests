select '{';
select '"type": "FeatureCollection",';
select '"features": [';

with 
  tertiarySubGraphs as (
SELECT *,3 as lvl FROM
xpath_table('region',
            'data',
            'zkir_xml',
            '/QualityReport/RoutingTestByLevel/Tertiary/SubgraphList/Subgraph/NumberOfRoads|/QualityReport/RoutingTestByLevel/Tertiary/SubgraphList/Subgraph/Bbox/Lat1|/QualityReport/RoutingTestByLevel/Tertiary/SubgraphList/Subgraph/Bbox/Lon1|/QualityReport/RoutingTestByLevel/Tertiary/SubgraphList/Subgraph/Bbox/Lat2|/QualityReport/RoutingTestByLevel/Tertiary/SubgraphList/Subgraph/Bbox/Lon2',
            'true')
AS t(region text, NumberOfRoads text, lat1 float, lon1 float, lat2 float, lon2 float))
, secondarySubGraphs as (
SELECT *,2 as lvl FROM
xpath_table('region',
            'data',
            'zkir_xml',
            '/QualityReport/RoutingTestByLevel/Secondary/SubgraphList/Subgraph/NumberOfRoads|/QualityReport/RoutingTestByLevel/Secondary/SubgraphList/Subgraph/Bbox/Lat1|/QualityReport/RoutingTestByLevel/Secondary/SubgraphList/Subgraph/Bbox/Lon1|/QualityReport/RoutingTestByLevel/Secondary/SubgraphList/Subgraph/Bbox/Lat2|/QualityReport/RoutingTestByLevel/Secondary/SubgraphList/Subgraph/Bbox/Lon2',
            'true')
AS t(region text, NumberOfRoads text, lat1 float, lon1 float, lat2 float, lon2 float))
, primarySubGraphs as (
SELECT *,1 as lvl FROM
xpath_table('region',
            'data',
            'zkir_xml',
            '/QualityReport/RoutingTestByLevel/Primary/SubgraphList/Subgraph/NumberOfRoads|/QualityReport/RoutingTestByLevel/Primary/SubgraphList/Subgraph/Bbox/Lat1|/QualityReport/RoutingTestByLevel/Primary/SubgraphList/Subgraph/Bbox/Lon1|/QualityReport/RoutingTestByLevel/Primary/SubgraphList/Subgraph/Bbox/Lat2|/QualityReport/RoutingTestByLevel/Primary/SubgraphList/Subgraph/Bbox/Lon2',
            'true')
AS t(region text, NumberOfRoads text, lat1 float, lon1 float, lat2 float, lon2 float))
, trunkSubGraphs as (
SELECT *,0 as lvl FROM
xpath_table('region',
            'data',
            'zkir_xml',
            '/QualityReport/RoutingTestByLevel/Trunk/SubgraphList/Subgraph/NumberOfRoads|/QualityReport/RoutingTestByLevel/Trunk/SubgraphList/Subgraph/Bbox/Lat1|/QualityReport/RoutingTestByLevel/Trunk/SubgraphList/Subgraph/Bbox/Lon1|/QualityReport/RoutingTestByLevel/Trunk/SubgraphList/Subgraph/Bbox/Lat2|/QualityReport/RoutingTestByLevel/Trunk/SubgraphList/Subgraph/Bbox/Lon2',
            'true')
AS t(region text, NumberOfRoads text, lat1 float, lon1 float, lat2 float, lon2 float))
, subGraphs as                                                        
(
select * from tertiarySubGraphs                                       
union
select * from secondarySubGraphs
union
select * from primarySubGraphs
union
select * from trunkSubGraphs
)
, uniqueSubGraphs as
(
select min(lvl) as lvl,region,NumberOfRoads,lat1,lon1,lat2,lon2
from subGraphs
group by region,NumberOfRoads,lat1,lon1,lat2,lon2
)
select '{"type":"Feature","properties":{"region":"'||region||'","level":"'||case when lvl=0 then 'trunk' when lvl=1 then 'primary' when lvl=2 then 'secondary' when lvl=3 then 'tertiary' else '' end||'","NumberOfRoads":"'||NumberOfRoads||'"},'||
       '"geometry":{"type":"Point","coordinates":['||(lon1+lon2)/2||','||(lat1+lat2)/2||']}},'
from uniqueSubGraphs
order by 1;

select '{"type":"Feature"}';
select ']}';                                                             