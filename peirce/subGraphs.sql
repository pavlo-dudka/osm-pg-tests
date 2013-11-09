select '{';
select '"type": "FeatureCollection",';
select '"features": [';

with subGraphs as (
SELECT * FROM
xpath_table('region',
            'data',
            'zkir_xml',
            '/QualityReport/RoutingTest/SubgraphList/Subgraph/NumberOfRoads|/QualityReport/RoutingTest/SubgraphList/Subgraph/Bbox/Lat1|/QualityReport/RoutingTest/SubgraphList/Subgraph/Bbox/Lon1|/QualityReport/RoutingTest/SubgraphList/Subgraph/Bbox/Lat2|/QualityReport/RoutingTest/SubgraphList/Subgraph/Bbox/Lon2',
            'true')
AS t(region text, NumberOfRoads text, lat1 float, lon1 float, lat2 float, lon2 float))
select '{"type":"Feature","properties":{"region":"'||region||'","NumberOfRoads":"'||NumberOfRoads||'"},'||
       '"geometry":{"type":"Point","coordinates":['||(lon1+lon2)/2||','||(lat1+lat2)/2||']}},'
from subGraphs
order by 1;

select ']}';                                                             
                                                                                 