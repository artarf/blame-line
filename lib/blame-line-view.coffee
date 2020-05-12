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
      if msg.body
        msg.body = "<pre>#{msg.body}</pre>"
      @element.innerHTML = """
      <div class="summary">#{msg.summary}#{msg.body}</div>
      <div>
        <span class="author">#{msg.author}</span> |
        #{parseDatetime(msg.authorTime).fromNow()} |
        <a target="_blank" class="blame-line-link"
            #{if msg.link? then '' else 'disabled'}
            href="#{msg.link ? ''}">#{msg.hash}</a>
        #{if msg.link? then '  [enter opens]' else ''}
      </div>
      """
    @element
