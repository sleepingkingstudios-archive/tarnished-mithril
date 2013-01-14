# app/views/js/console.coffee

jQuery(document).ready () ->
  self = jQuery this
  
  output = jQuery '#console-output'
  output.append '<li>Greetings, program!</li>'
  
  form  = jQuery 'form#console-input'
  input = form.find 'input#input-field'
  
  form.bind 'submit', (event) ->
    event.preventDefault();
    event.stopPropagation();
    
    value = input.val()
    input.val ''
    
    unless null == value || 0 == value.length
      output.append '<li>&gt; ' + value + '</li>'
      jQuery.ajax '/?text=' + value, { complete: remoteSuccess }
  
  processOutput = (text) ->
    text = text.replace(/\n/g, '<br />');
    return text
  
  remoteSuccess = (xhr, status) ->
    response = jQuery.parseJSON xhr.responseText
    
    console.log "Remote complete!"
    console.log "response = " + response.text
    
    output.append '<li>' + processOutput(response.text) + '</li>'
    offset = self.height() - jQuery(window).height()
    console.log "offset = " + offset
    self.scrollTop offset
