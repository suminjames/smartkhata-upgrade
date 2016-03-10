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

manage_cheque_all_select = () ->
  $("select.select-ledger").each ->
    $this = $(this)
    manage_cheque($this)

ready = ->
  jQuery ->
    $(document).on 'click','.asdd_fields', (event) ->
      time = new Date().getTime()
      regexp = new RegExp($(this).data('id'),'g')
      $(this).before($(this).data('fields').replace(regexp,time))
      event.preventDefault()
      debugger;
      $('select.combobox').combobox()
      manage_cheque_all_select()
  jQuery ->
    $('select.combobox').combobox()
$(document).ready(ready)

$(document).on 'click','.add_fields', (event) ->
  time = new Date().getTime()
  regexp = new RegExp($(this).data('id'),'g')
  $(this).before($(this).data('fields').replace(regexp,time))
  event.preventDefault()
  debugger;
  $('select.combobox').combobox()
  manage_cheque_all_select()

manage_cheque = ($this) ->
  $val = $this.val()
  if ($this.find("option[value="+$val+"]").text().indexOf('Bank:') == 0)
    $this.parent().parent().find('.cheque').show()
  else
    $this.parent().parent().find('.cheque').hide()


$ ->
  manage_cheque_all_select()

$ ->
  $(document).on 'change','select.select-ledger', (event) ->
    $this = $(this)
    manage_cheque($this)

$ ->
  $('#new_voucher').on 'submit', (event) ->
    $(".particular").each ->
      $this = $(this)
      if (parseFloat($this.find('.voucher_particulars_amnt input').val()) == 0)
        $this.remove()


    $("select.select-ledger").each ->
      $this = $(this)
      $val = $val = $this.val()
      if ($this.find("option[value="+$val+"]").text().indexOf('Bank:') == 0)
        $input = $this.parent().parent().find('.cheque input')
        if($input.val().trim().length == 0)
          $input.parent().addClass('has-error')
          $input.parent().append('<p class="error">Cheque cant be empty</p>')
          event.preventDefault()
        else
          $input.parent().removeClass('has-error')
          $input.parent().find('p.error').hide()
