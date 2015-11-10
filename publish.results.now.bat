rem @set publish_path=
rem @set publish_url=https://dl.dropboxusercontent.com/u/14107903/test
rem call publish.results.bat

@set publish_path=D:\TEMP\osm-pg-tests-pages
@set publish_url=http://pavlo-dudka.github.io/osm-pg-tests
call git-pull.bat
call publish.results.bat
call git-push.bat