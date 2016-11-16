#!/usr/bin/env python
import git
import os
import web

urls = (
  '/errors/(.*)/since/(.*)', 'list_errors_since',
)

app = web.application(urls, globals())

class validator:
  @staticmethod
  def errors(filename, since_date):
    web.header('Access-Control-Allow-Origin', '*')
    web.header('Access-Control-Allow-Credentials', 'true')
    repo = git.Repo('/home/osm-pg-tests-gh-pages')
    commit = repo.git.rev_list('-n1', '--before', since_date, 'gh-pages')
    if commit == '':
      commit = repo.git.log('--diff-filter=A', 'geojson/'+filename).split('\n')[0].split(' ')[1]
    lines = repo.git.diff('-p','--stat', commit, 'geojson/'+filename).split('\n')
    return [line[1:] for line in lines if line.startswith('+') & ('properties' in line)]

class list_errors_since:        
  def GET(self, filename, since_date):
    response = ['{','"type": "FeatureCollection",','"features": [']
    response.extend(validator.errors(filename+'.geojson', since_date))
    response.extend(['{"type":"Feature"}',']}'])
    return '\n'.join(response)

if __name__ == "__main__":
    app.run()
                  