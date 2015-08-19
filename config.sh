#!/bin/sh

host=localhost
port=5432
username=andygol
password=
database=osm
pgbin_folder="/usr/local/Cellar/postgresql/9.4.4/bin"
psql_exe="psql -h $host -p $port -U $username -w -d $database -A -t -q"
pg_data_folder="/Users/andygol/Documents/github/osm-pg-tests/osm/"
