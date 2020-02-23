_peekDisposable = null

dispose = (set)->
  return unless set
  d.dispose() for d in Array.from set

module.exports = (editor, line, markerOpts, keyHandler)->
  dispose _peekDisposable
  _peekDisposable = new Set
  marker = editor.markBufferRange [[line,0],[line,0]], invalidate:'touch'
  _peekDisposable.add dispose: -> marker.destroy()
  editor.decorateMarker marker, markerOpts
  editor.element.addEventListener 'keydown', listener = (e)->
    key = (if e.ctrlKey then 'ctrl-' else '') + e.key
    dispose _peekDisposable if keyHandler[key]? e
  _peekDisposable.add dispose: -> editor.element.removeEventListener 'keydown', listener
  _peekDisposable.add editor.onDidChangeCursorPosition ({newBufferPosition})->
    return if newBufferPosition.row is line
    dispose _peekDisposable
    # focus moves to Atom <body> when link is clicked and then returning to Atom
    # => editor becomes unresponsive
    # This fixes it:
    editor.getElement().focus()
  _peekDisposable.add dispose: -> _peekDisposable = null
  editor.scrollToCursorPosition()
