# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/


# ready = ->
#   jQuery ->
# 		$('form').on 'click', '.add_fields', (event) ->
# 			time = new Date().getTime()
# 			regexp = new RegExp($(this).data('id'),'g')
# 			$(this).before($(this).data('fields').replace(regexp,time))
# 			event.preventDefault()
#       $('.combobox').combobox()
#
#   jQuery ->
#     $('.combobox').combobox();
# $(document).ready(ready)

ready = ->
  jQuery ->
    $('form').on 'click','.add_fields', (event) ->
      time = new Date().getTime()
      regexp = new RegExp($(this).data('id'),'g')
      $(this).before($(this).data('fields').replace(regexp,time))
      event.preventDefault()
      debugger;
      $('select.combobox').combobox()
  jQuery ->
    $('select.combobox').combobox()
$(document).ready(ready)


$ ->
  $('select.combobox').on 'change', (event) ->
    $this = $(this)
    $val = $this.val()
    if ($("select.combobox option[value="+$val+"]").text().indexOf('Bank:') == 0)
      $this.parent().parent().find('.cheque').show()
    else
      $this.parent().parent().find('.cheque').hide()
$ ->
  $('#new_voucher').on 'submit', (event) ->
    event.preventDefault()
    $("select.combobox").each ->
      $this = $(this)
      $val = $val = $this.val()
      if ($this.find("option[value="+$val+"]").text().indexOf('Bank:') == 0)
        console.log('asd')
      else
        console.log('asdfdd')
