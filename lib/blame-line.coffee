BlameLineView = require './blame-line-view'
{CompositeDisposable} = require 'atom'

module.exports = BlameLine =
  blameLineView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @blameLineView = new BlameLineView(state.blameLineViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @blameLineView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'blame-line:toggle': => @toggle()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @blameLineView.destroy()

  serialize: ->
    blameLineViewState: @blameLineView.serialize()

  toggle: ->
    console.log 'BlameLine was toggled!'

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()
