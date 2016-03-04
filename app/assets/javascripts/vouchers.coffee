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
