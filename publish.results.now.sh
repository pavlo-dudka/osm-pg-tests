#!/bin/sh

publish_path="/Users/andygol/Documents/github/osm-pg-tests-gh-pages" #локальна тека
publish_url="http://pavlo-dudka.github.io/osm-pg-tests"

if [ -e publish.results.sh ]; then
  source ./publish.results.sh
fi

if [ -e git-push.sh ]; then
  ./git-push.sh
fi

exit 0
