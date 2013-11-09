select '{';
select '"type": "FeatureCollection",';
select '"features": [';

with deadEnds as (
SELECT * FROM
xpath_table('region',
            'data',
            'zkir_xml',
            '/QualityReport/DeadEndsTest/DeadEndList/DeadEnd/Coord/Lat|/QualityReport/DeadEndsTest/DeadEndList/DeadEnd/Coord/Lon',
            'true')
AS t(region text, lat text, lon text))
select '{"type":"Feature","properties":{"region":"'||region||'"},'||
       '"geometry":{"type":"Point","coordinates":['||lon||','||lat||']}},'
from deadEnds
order by 1;

select ']}';                                                             