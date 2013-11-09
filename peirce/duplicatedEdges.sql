select '{';
select '"type": "FeatureCollection",';
select '"features": [';

with duplicatedEdges as (
SELECT * FROM
xpath_table('region',
            'data',
            'zkir_xml',
            '/QualityReport/RoadDuplicatesTest/DuplicateList/DuplicatePoint/Coord/Lat|/QualityReport/RoadDuplicatesTest/DuplicateList/DuplicatePoint/Coord/Lon',
            'true')
AS t(region text, lat text, lon text))
select '{"type":"Feature","properties":{"region":"'||region||'"},'||
       '"geometry":{"type":"Point","coordinates":['||lon||','||lat||']}},'
from duplicatedEdges
order by 1;

select ']}';                                                             