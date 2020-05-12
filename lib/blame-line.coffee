BlameLineView = require './blame-line-view'
path = require 'path'
X = require 'execa'
{CompositeDisposable} = require 'atom'
{shell} = require('electron')
peekMarker = require './peek'
repoUrl = require('./repo-url')

camelize = (string) ->
  return '' unless string
  string.replace /[_-]+(\w)/g, (m) -> m[1].toUpperCase()

parse = (out)->
  [hash, lines..., theLine, _] = out.split('\n')
  map = {hash:hash.split(' ')[0]}
  for l in lines
    [a, b...] = l.split ' '
    map[camelize a] = if ['summary','author'].includes(a) then b.join ' ' else b[0]
  map

module.exports = BlameLine =
  view: null
  subscriptions: null

  activate: ->
    @view = new BlameLineView()
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace', 'blame-line:blame': => @blame()

  deactivate: ->
    @subscriptions.dispose()

  blame: ->
    return unless e = atom.workspace.getActiveTextEditor()
    line = e.getLastCursor().getBufferRow()
    filePath = e.getBuffer().getPath()
    f = path.basename filePath
    cwd = path.dirname filePath
    try
      promises = [
        X 'git', ['blame', f, '--line-porcelain', '-L', "#{line + 1},+1"], {cwd}
        X 'git', ['remote', '-v'], {cwd}
      ]
      [result, remote] = await Promise.all(promises)
      if xx = parse result.stdout
        if remote?.stdout?.trim()
          url = remote.stdout.split(/\s+/)[1]
          if url.indexOf('https://') is -1
            url = 'https://' + url.replace('git@', '').replace(':', '/')
          url = url.replace('.git', '')
          # check the origin's host. if bitbucket, we have some formatting to do
          if (url.indexOf('@bitbucket') isnt -1)
            # we want everything after the @
            url = "https://" + url.split('@')[1]
        if url?.includes 'bitbucket'
          xx.link = "#{url}/commits/#{xx.hash}" if url
        else
          xx.link = "#{url}/commit/#{xx.hash}" if url
        show = await X 'git', ['show', xx.hash, '--format=%h%x00%b%x00'], {cwd}
        [hash, body] = show.stdout.split('\0').slice(0,2)
        xx.hash = hash
        xx.body = body
        markerOpts = {type:'block', position:'before', item: @view.render xx}
        aye = -> true
        peekMarker e, line, markerOpts, "ctrl-c": aye, escape: aye, enter: (e)->
          e.stopPropagation()
          if xx.link
            shell.openExternal(xx.link)
          else if xx.author isnt 'Not Committed Yet'
            n = atom.notifications.addInfo 'No external repository', dismissable: true
            setTimeout n.dismiss.bind(n), 4000
          true
    catch e
      if e.command?
        atom.notifications.addError e.command, details: e.message + '\n' + e.stderr
      else
        console.error e.stack
