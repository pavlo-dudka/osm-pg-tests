cd results
copy /Y *.geojson %publish_path%\geojson\
copy /Y *.geojsont %publish_path%\geojson\
copy /Y *.txt %publish_path%\txt\

move error.hash error.old.hash
move error.summary error.old.summary
call ..\binaries\md5sum.exe *.geojson > error.hash
find /c "josm" *.geojson > error.count.txt

set hash=

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
if "%errdate%" equ "" (set errdate=%date% %time%)
echo %file%^|%~2^|%errdate%>> error.summary
goto :eof

:gethash
set hash=
for /f "tokens=1,2 delims=*" %%e IN (%~1) do (if /i "%%f"=="%~2" (set hash=%%e))
goto :eof

:recordItem
echo ^<item^> >> test.rss
echo ^<guid^>%~1 %~3 v2^</guid^> >> test.rss
set file=%~1
set file=%file:~0,-8%
echo ^<link^>%publish_url%/%file%.html^</link^> >> test.rss
echo ^<author^>dudka^</author^> >> test.rss
echo ^<title^> >> test.rss
echo %file% - %~2 error(s) found at %~3 >> test.rss
echo ^</title^> >> test.rss
echo ^<description^> >> test.rss
echo %~2 error(s) found >> test.rss
echo ^</description^> >> test.rss
echo ^</item^> >> test.rss
goto :eof