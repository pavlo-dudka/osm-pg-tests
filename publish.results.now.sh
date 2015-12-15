#!/bin/bash

publish_path="/home/osm-pg-tests-gh-pages" #локальна тека
publish_url="http://pavlo-dudka.github.io/osm-pg-tests"

if [ -e publish.results.sh ]; then
  source ./publish.results.sh
fi

if [ -e git-push.sh ]; then
  source ./git-push.sh
fi

exit 0
