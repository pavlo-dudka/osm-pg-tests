#!/bin/sh

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
    errdate=$(date +%d\.%m\.%Y' '%H\:%M\:%S)
  fi

  echo "$file $2 $errdate" >> error.summary
}

recordItem () {
  echo \<item\> >> test.rss
  echo \<guid\>$1 $3\</guid\> >> test.rss
  file=(`echo $1|sed 's/.geojson.*$//'`)
  echo \<link\>$publish_url/test.html?$file\</link\> >> test.rss
  peirce=${file:0:6}
  if [[ "$peirce" = "peirce" ]]
    then
      echo \<author\>Ch.S. Peirce\</author\> >> test.rss
    else
      echo \<author\>dudka\</author\> >> test.rss
  fi

    echo \<title\>$file - $2 error\(s\) found at $3\</title\> >> test.rss
    echo \<description\>\<![CDATA[$2 error"("s")" found: \<a href="$publish_url/test.html?map?$file"\>map\</a\> \<a href="$publish_url/test.html?table?$file"\>table\</a\>]]\>\</description\> >> test.rss
    echo \<pubDate\>"$3"\</pubDate\> >> test.rss
    echo \</item\> >> test.rss
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

md5 -r *.geojson > error.hash

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

mv *.hidden *.geojson

while read line; do
  echo "processing geojson param: $line" #debug output
  param=($line)
  processGeojson ${param[0]} ${param[1]}
done < error.count.txt

echo \<?xml version=\"1.0\" encoding=\"utf-8\"?\> > test.rss
echo \<rss version=\"2.0\"\> >> test.rss
echo \<channel\> >> test.rss
echo \<title\>Quality Assurance "("OSM Ukraine")"\</title\> >> test.rss
echo \<link\>$publish_url/test.html\</link\> >> test.rss
echo \<lastBuildDate\>`LC_TIME=en_US.UTF-8 date`\</lastBuildDate\> >> test.rss

while read line; do
  recordItem $line
done < error.summary

echo \</channel\> >> test.rss
echo \</rss\> >> test.rss

cp -f error.count.txt $publish_path/txt/
cp -f test.rss $publish_path/
rm error.old.hash
rm error.old.summary
cd ..
