drop table if exists addressErrorList;
create table addressErrorList as
SELECT * FROM
xpath_table('region',
            'data',
            'zkir_xml',
            '/QualityReport/AddressTest/AddressErrorList/House/ErrType|/QualityReport/AddressTest/AddressErrorList/House/City|/QualityReport/AddressTest/AddressErrorList/House/Street|/QualityReport/AddressTest/AddressErrorList/House/HouseNumber|/QualityReport/AddressTest/AddressErrorList/House/Coord/lat|/QualityReport/AddressTest/AddressErrorList/House/Coord/lon',
            'true')
AS t(region text, ErrType text, City text, Street text, HouseNumber text, lat text, lon text);