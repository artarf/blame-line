module.exports = (f)->
  x = Promise.all atom.project.getDirectories().map (dir)->
    if f.startsWith dir.path
      atom.project.repositoryForDirectory dir
  x.then (repos)->
    for r in repos when r?
      continue unless origin = r.getOriginURL()
      if origin.indexOf('https://') is -1
        origin = 'https://' + origin.replace('git@', '').replace(':', '/')
      originUrl = origin.replace('.git', '')
      # check the origin's host.  if bitbucket, we have some formatting to do
      if (originUrl.indexOf('@bitbucket') isnt -1)
        # we want everything after the @
        return "https://" + originUrl.split('@')[1]
      return originUrl
