#!/bin/sh

#publish_path=C:/Users/pdudka.ILS-UA/Dropbox/Public/test
#publish_url=https://dl.dropboxusercontent.com/u/14107903/test
#call publish.results.bat

publish_path=C:/Users/pdudka.ILS-UA/Downloads/osm-pg-tests-page
publish_url=http://pavlo-dudka.github.io/osm-pg-tests
./publish.results.sh
call git-push.bat
