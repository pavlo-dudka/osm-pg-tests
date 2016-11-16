#!/bin/sh

git --git-dir=$publish_path/.git --work-tree=$publish_path commit -a -m "validation (`date +%d/%m/%Y' '%H:%M`)"
git --git-dir=$publish_path/.git --work-tree=$publish_path push origin gh-pages
