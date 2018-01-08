_peekDisposable = null

dispose = (set)->
  return unless set
  d.dispose() for d in Array.from set

module.exports = (editor, line, item, enter)->
  dispose _peekDisposable
  _peekDisposable = new Set
  marker = editor.markBufferRange [[line,0],[line,0]], invalidate:'touch'
  _peekDisposable.add dispose: -> marker.destroy()
  editor.decorateMarker marker, {type:'block', position:'before', item }
  editor.element.addEventListener 'keydown', listener = (e)->
    if e.key is 'Escape' or (e.key is 'c' and e.ctrlKey)
      dispose _peekDisposable
    else if e.key is 'Enter' and enter?(e)
      dispose _peekDisposable
  _peekDisposable.add dispose: -> editor.element.removeEventListener 'keydown', listener
  _peekDisposable.add editor.onDidChangeCursorPosition ({newBufferPosition})=>
    return if newBufferPosition.row is line
    dispose _peekDisposable
    # focus moves to Atom <body> when link is clicked and then returning to Atom
    # => editor becomes unresponsive
    # This fixes it:
    editor.getElement().focus()
  _peekDisposable.add dispose: -> _peekDisposable = null
