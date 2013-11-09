select '{';
select '"type": "FeatureCollection",';
select '"features": [';

with citiesWithoutPlacePolygon as (
SELECT * FROM
xpath_table('region',
            'data',
            'zkir_xml',
            '/QualityReport/AddressTest/CitiesWithoutPlacePolygon/City/City|/QualityReport/AddressTest/CitiesWithoutPlacePolygon/City/Coord/lat|/QualityReport/AddressTest/CitiesWithoutPlacePolygon/City/Coord/lon',
            'true')
AS t(region text, City text, lat text, lon text))
select '{"type":"Feature","properties":{"region":"'||region||'","city":"'||city||'"},'||
       '"geometry":{"type":"Point","coordinates":['||lon||','||lat||']}},'
from citiesWithoutPlacePolygon
order by 1;

select ']}';