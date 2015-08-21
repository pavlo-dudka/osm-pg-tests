#!/bin/sh

cd $publish_path
git commit -a -m "validation (`date +%d/%m/%Y' '%H:%M`)"
git push origin gh-pages

exit 0
