#!/bin/sh

git --git-dir=$publish_path/.git --work-tree=$publish_path pull origin gh-pages
