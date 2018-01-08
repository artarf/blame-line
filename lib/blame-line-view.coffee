moment = require 'moment'

parseDatetime = (millis)-> moment new Date parseInt millis + '000'

module.exports =
class BlameLineView
  constructor: ->
    @element = document.createElement('div')
    @element.classList.add('blame-line')

  render: (msg)->
    if msg.error
      @element.innerHTML = "#{msg.stderr}<br/>#{msg.error.message}"
    else if msg.author is 'Not Committed Yet'
      @element.innerHTML = "[Not committed yet]"
    else
      @element.innerHTML = """
      <div class="summary">#{msg.summary}</div>
      <div>
        <span class="author">#{msg.author}</span> |
        #{parseDatetime(msg.authorTime).fromNow()} |
        <a target="_blank" class="blame-line-link"
            #{if msg.link? then '' else 'disabled'}
            href="#{msg.link ? ''}">#{msg.hash.slice 0, 8}</a>
      </div>
      """
    @element
