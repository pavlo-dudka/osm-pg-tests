#!/bin/bash

# functions declaration
# =====================
gethash () {
  hash=
  while read line; do
    test=($line)
    if [[ "${test[1]}" = "$2" ]]; then
      hash=${test[0]}
    fi
  done < $1
}
                                     
processGeojson () {
  file=$1

  gethash error.hash $file
  newhash=$hash

  gethash error.old.hash $file
  oldhash=$hash

  errdate=

  if [[ "$newhash" = "$oldhash" ]]; then
    while read c; do
      test=($c)
      if [[ "${test[0]}" = "$file" ]]; then
        errdate="${test[2]}"
      fi
    done < error.old.summary
  fi

  if [ -z "$errdate" ]; then
    errdate=$(date +'%Y-%m-%dT%H:%M')
  fi

  echo "$file $2 $errdate" >> error.summary
  echo "`date +'%Y-%m-%d %H:%M'`,$2" >> "/var/www/csv/$file.csv"
}

recordItem () {
  errdate=$3
  file=(`echo -e $1|sed 's/.geojson.*$//'`)
  commit=`git --git-dir=$publish_path/.git --work-tree=$publish_path rev-list -n1 --before "3 days ago" gh-pages`
  diff_3d="`git --git-dir=$publish_path/.git --work-tree=$publish_path diff --shortstat $commit $publish_path/geojson/$file.geojson`"
  commit=`git --git-dir=$publish_path/.git --work-tree=$publish_path rev-list -n1 --before "10 days ago" gh-pages`
  diff_10d="`git --git-dir=$publish_path/.git --work-tree=$publish_path diff --shortstat $commit $publish_path/geojson/$file.geojson`"
  echo "<item>" >> test.rss
  echo "<guid isPermaLink=\"false\">${file//./}`date -d $errdate +'%Y%m%d%H%M'`</guid>" >> test.rss
  echo "<link>$publish_url/test.html?$file</link>" >> test.rss
  echo "<author>pavlo.dudka@gmail.com (Pavlo Dudka)</author>" >> test.rss
  echo "<title>$file - $2 error(s) found at `date -d $errdate +'%d %b %Y %H:%M'`</title>" >> test.rss
  echo "<description><![CDATA[$2 error(s) found: <a href=$publish_url/test.html?map?$file>map</a> <a href=$publish_url/test.html?table?$file>table</a>]]></description>" >> test.rss
  echo "<pubDate>`date -d $errdate +'%a, %d %b %Y %T %z'`</pubDate>" >> test.rss
  echo "<gitDiff3d>$diff_3d</gitDiff3d>" >> test.rss
  echo "<gitDiff10d>$diff_10d</gitDiff10d>" >> test.rss

  echo "</item>" >> test.rss
}


# main
# ====

cd results

if [ ! -d $publish_path"/geojson/" ]
  then
    mkdir $publish_path"/geojson/"
fi

cp -f *.geojson "$publish_path/geojson/"

if [ ! -d $publish_path"/txt/" ]
  then
    mkdir $publish_path"/txt/"
fi

cp -f *.txt $publish_path"/txt/"

mv error.hash error.old.hash
mv error.summary error.old.summary
mv house.numbers.geojson house.numbers.hidden
mv kyiv.building.levels.geojson kyiv.building.levels.hidden
mv non-uk.geojson non-uk.hidden
mv railway.dead.ends.geojson railway.dead.ends.hidden
mv decommunization.geojson decommunization.hidden

md5sum *.geojson > error.hash

if [ -e error.count.txt ]
  then
    cat /dev/null > error.count.txt
  else
    touch error.count.txt
fi

for a in *.geojson
do
  echo $a `grep -c "properties" $a` >> error.count.txt
done

for file in *.hidden
do
 mv "$file" "${file%.hidden}.geojson"
done

while read line; do
  echo "processing geojson param: $line" #debug output
  param=($line)
  processGeojson ${param[0]} ${param[1]}
done < error.count.txt

date +'%Y-%m-%dT%H:%M' > /var/www/csv/version

echo -e '<?xml version="1.0" encoding="utf-8" ?>' > test.rss
echo -e '<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">' >> test.rss
echo -e '<channel>' >> test.rss
echo -e '<title>Quality Assurance (OSM Ukraine)</title>' >> test.rss
echo -e '<description>Quality Assurance (OSM Ukraine)</description>' >> test.rss
echo -e '<link>'$publish_url'/test.html</link>' >> test.rss
echo -e '<atom:link href="'$publish_url'/test.rss" rel="self" type="application/rss+xml"/>' >> test.rss

while read line; do
  recordItem $line
done < error.summary

echo -e '</channel>' >> test.rss
echo -e '</rss>' >> test.rss

cp -f error.count.txt $publish_path/txt/
cp -f test.rss $publish_path/
rm error.old.hash
rm error.old.summary
cd ..
