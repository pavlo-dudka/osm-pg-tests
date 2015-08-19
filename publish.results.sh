#!/bin/sh

# http://stackoverflow.com/questions/8742783/returning-value-from-called-function-in-shell-script

# functions declaration
# =====================
gethash () {
  hash=''
  for e in $1
  do
    if [ (cut -d '*' -f2 $e) -eq $2 ]
      then
      hash=(cut -d '*' -f1 $e)
    fi
  done

  return "$hash" #вивід в stdout
}

processGeojson () {
file=$1
file=${file:0:2}
for g in *.geojson
do
  if [ $g -eq $file ]
    then
    $file=$g
  fi
done
gethash error.hash $file
hash=$? #отримуємо значення $hash з stdout після виконання gethash
newhash=$hash

gethash error.old.hash $file
hash=$?
oldhash=$hash

errdate=''
if [ $newhash -eq $oldhash ]
  then
  for c in error.old.summary
  do
    if [ (cut -d '|' -f1 $c) -eq $file ]
      then errdate=(cut -d '|' -f3 $c)
    fi
  done
  if [ $errdate -eq '' ]
    then
    $errdate=(date +%d%m%y%H%M%S)
  fi
  echo $file\|$2\|$errdate >> error.summary
}

recordItem () {
  echo \<item\> >> test.rss
  echo \<guid\>$1 $3\</guid\> >> test.rss
  file=$1
  file=${file:0:8}
  echo \<link\>$publish_url/test.html?$file\</link\> >> test.rss
  peirce=${file:0:6}
  if [ $peirce -eq "peirce" ]
    then
    echo \<author\>Ch.S. Peirce\</author\> >> test.rss
  fi
  if [ $Peirce -ne "peirce" ]
    then
    echo \<author\>dudka\</author\> >> test.rss
  fi
    echo \<title\>$file - $2 error(s) found at $3\</title\> >> test.rss
    echo \<description\>\<![CDATA[$2 error(s) found: \<a href="$publish_url/test.html?map?$file"\>map\</a\> \<a href="$publish_url/test.html?table?$file"\>table\</a\>]]\>\</description\> >> test.rss
    echo \</item\> >> test.rss
}

# main
# ====

cd results
cp -f *.geojson $publish_path/geojson/
cp -f *.geojsont $publish_path/geojson/
cp -f *.txt $publish_path/txt/

mv error.hash error.old.hash
mv error.summary error.old.summary
mv house.numbers.geojson house.numbers.hidden
mv kyiv.building.levels.geojson kyiv.building.levels.hidden
mv non-uk.geojson non-uk.hidden
md5 *.geojson > error.hash
grep -c "properties" *.geojson > error.count.txt
mv *.hidden *.geojson

for a in error.count.txt
do
  processGeojson (cut -d ' ' -f2,3 $a)
done

echo \<?xml version=\"1.0\" encoding=\"utf-8\"?\> > test.rss
echo \<rss version=\"2.0\"\> >> test.rss
echo \<channel\> >> test.rss
echo \<title\>Quality Assurance (OSM Ukraine)\</title\> >> test.rss
echo \<link\>$publish_url/test.html\</link\> >> test.rss

for a in error.summary
do
  recordItem (cut -d '|' -f1,2,3 $a)
done

echo \</channel\> >> test.rss
echo \</rss\> >> test.rss

cp -f error.count.txt $publish_path\txt\
cp -f test.rss $publish_path\
rm error.old.hash
rm error.old.summary
cd ..

exit 0
