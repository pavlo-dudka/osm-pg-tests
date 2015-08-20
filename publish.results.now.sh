#!/bin/sh

publish_path=~/Downloads/osm-pg-tests-page #локальна тека
publish_url=http://pavlo-dudka.github.io/osm-pg-tests
./publish.results.sh
./git-push.sh
