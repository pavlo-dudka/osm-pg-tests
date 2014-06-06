@echo off

call config.bat

binaries\wget.exe http://peirce.zkir.ru/qa/UA-C/rss -O temp\UA-C.rss
binaries\wget.exe http://peirce.zkir.ru/qa/UA-E/rss -O temp\UA-E.rss
binaries\wget.exe http://peirce.zkir.ru/qa/UA-N/rss -O temp\UA-N.rss
binaries\wget.exe http://peirce.zkir.ru/qa/UA-S/rss -O temp\UA-S.rss
binaries\wget.exe http://peirce.zkir.ru/qa/UA-W/rss -O temp\UA-W.rss

:wait_wget
tasklist /FI "IMAGENAME eq wget.exe" 2>NUL | find /I /N "wget.exe">NUL
if "%ERRORLEVEL%" equ "0" timeout 1
if "%ERRORLEVEL%" equ "0" goto :wait_wget

move temp\rss.hash temp\rss.hash.bak
binaries\md5sum.exe temp\*.rss > temp\rss.hash

set hash=
for /f %%a in ('dir /b temp\*.rss') do (call :processRss %%a)

%psql_exe% -f peirce\import.sql

start "peirce.citiesWithoutPlacePolygon" %psql_exe%  -f peirce\citiesWithoutPlacePolygon.sql -o results\peirce.citiesWithoutPlacePolygon.geojson -q
rem start "peirce.duplicatedEdges" %psql_exe%  -f peirce\duplicatedEdges.sql -o results\peirce.duplicatedEdges.geojson -q
rem start "peirce.deadEnds" %psql_exe%  -f peirce\deadEnds.sql -o results\peirce.deadEnds.geojson -q
start "peirce.subGraphs" %psql_exe%  -f peirce\subGraphs.sql -o results\peirce.subGraphs.geojson -q
start "peirce.tertiarySubGraphs" %psql_exe%  -f peirce\tertiarySubGraphs.sql -o results\peirce.tertiarySubGraphs.geojson -q

:wait_psql
tasklist /FI "IMAGENAME eq psql.exe" 2>NUL | find /I /N "psql.exe">NUL
if "%ERRORLEVEL%" equ "0" timeout 1
if "%ERRORLEVEL%" equ "0" goto :wait_psql
goto :eof


:processRss
call :gethash temp\rss.hash %~1
set newhash=%hash%
call :gethash temp\rss.hash.bak %~1
set oldhash=%hash%
set file=%~1
set region=%file:~0,-4%
if "%newhash%" neq "%oldhash%" (binaries\wget.exe http://peirce.zkir.ru/ADDR_CHK/%region%.mp_addr.xml -O "%pg_data_folder%\%region%.mp_addr.xml")
goto :eof

:gethash
set hash=
for /f "tokens=1,2 delims=*" %%e IN (%~1) do (if /i "%%f"=="temp\%~2" (set hash=%%e))
goto :eof