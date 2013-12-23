call peirce.bat

@set publish_path=C:\Users\pdudka.ILS-UA\Dropbox\Public\test
@set publish_url=http://dl.dropboxusercontent.com/u/14107903/test
call publish.results.bat

@set publish_path=C:\Users\pdudka.ILS-UA\Downloads\osm-pg-tests-page
@set publish_url=http://pavlo-dudka.github.io/osm-pg-tests
call publish.results.bat
call git-push.bat