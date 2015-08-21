#!/bin/sh

publish_path="/Users/andygol/Documents/github/osm-pg-tests-gh-pages"

cd $publish_path
git commit -a -m "validation (`date +%d/%m/%Y' '%H:%M`)"
git push origin gh-pages

exit 0
