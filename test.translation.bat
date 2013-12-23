%psql_exe% -f sql\osm.trans.errors.sql -o results\osm.trans.errors.txt
start "trans.ua" %psql_exe% -f sql\osm.trans.uk.sql -o results\osm.trans.uk.txt
start "trans.ru" %psql_exe% -f sql\osm.trans.ru.sql -o results\osm.trans.ru.txt
exit