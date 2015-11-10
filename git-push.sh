#!/bin/sh

git -C $publish_path commit -a -m "validation (`date +%d/%m/%Y' '%H:%M`)"
git -C $publish_path push origin gh-pages
