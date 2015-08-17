#!/bin/sh

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

hash=""

for /f "tokens=2,3 delims= " %%a IN (error.count.txt) DO (call :processGeojson %%a %%b)

echo ^<?xml version=^"1.0^" encoding=^"utf-8^"?^> > test.rss
echo ^<rss version=^"2.0^"^> >> test.rss
echo ^<channel^> >> test.rss
echo ^<title^>Quality Assurance (OSM Ukraine)^</title^> >> test.rss
echo ^<link^>%publish_url%/test.html^</link^> >> test.rss
for /f "tokens=1,2,3 delims=|" %%a IN (error.summary) DO (call :recordItem %%a %%b "%%c")
echo ^</channel^> >> test.rss
echo ^</rss^> >> test.rss

copy /Y error.count.txt %publish_path%\txt\
copy /Y test.rss %publish_path%\
del error.old.hash
del error.old.summary
cd ..
goto :eof

:processGeojson
set file=%~1
set file=%file:~0,-2%
for /f %%g in ('dir /b *.geojson') do (if /i "%%g"=="%file%" (set file=%%g))
call :gethash error.hash %file%
set newhash=%hash%
call :gethash error.old.hash %file%
set oldhash=%hash%
set errdate=
if "%newhash%" equ "%oldhash%" (for /f "tokens=1,3 delims=|" %%c in (error.old.summary) do (if /i "%%c"=="%file%" (set errdate=%%d)))
if "%errdate%" equ "" (set errdate=%date% %time:~0,5%)
echo %file%^|%~2^|%errdate%>> error.summary
goto :eof

:gethash
set hash=
for /f "tokens=1,2 delims=*" %%e IN (%~1) do (if /i "%%f"=="%~2" (set hash=%%e))
goto :eof

:recordItem
echo ^<item^> >> test.rss
echo ^<guid^>%~1 %~3^</guid^> >> test.rss
set file=%~1
set file=%file:~0,-8%
echo ^<link^>%publish_url%/test.html?%file%^</link^> >> test.rss
set peirce=%file:~0,6%
if "%peirce%" equ "peirce" echo ^<author^>Ch.S. Peirce^</author^> >> test.rss
if "%peirce%" neq "peirce" echo ^<author^>dudka^</author^> >> test.rss
echo ^<title^>%file% - %~2 error(s) found at %~3^</title^> >> test.rss
echo ^<description^>^<![CDATA[%~2 error(s) found: ^<a href="%publish_url%/test.html?map?%file%"^>map^</a^> ^<a href="%publish_url%/test.html?table?%file%"^>table^</a^>]]^>^</description^> >> test.rss
echo ^</item^> >> test.rss
goto :eof
