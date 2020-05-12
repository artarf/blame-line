BlameLineView = require './blame-line-view'
path = require 'path'
{ exec } = require 'child_process'
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
    cmdText = "git blame #{filePath} --line-porcelain -L #{line + 1},+1"
    exec cmdText, {cwd: path.dirname(filePath)}, (error, stdout, stderr)=>
      repoUrl(e.getPath()).then (url)=>
        xx = if error then {error, stderr} else parse stdout
        if url?.includes 'bitbucket'
          xx.link = "#{url}/commits/#{xx.hash}" if url
        else
          xx.link = "#{url}/commit/#{xx.hash}" if url
        markerOpts = {type:'block', position:'before', item: @view.render xx}
        aye = -> true
        peekMarker e, line, markerOpts, "ctrl-c": aye, escape: aye, enter: (e)->
          return if error
          e.stopPropagation()
          if xx.link
            shell.openExternal(xx.link)
          else if xx.author isnt 'Not Committed Yet'
            n = atom.notifications.addInfo 'No external repository', dismissable: true
            setTimeout n.dismiss.bind(n), 4000
          true
