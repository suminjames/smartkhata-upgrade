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

fix_autocomplete = () ->
  $('.combobox-container input:text').each ->
    $(this).attr('autocomplete','off')

ready = ->
  jQuery ->
    $('select.combobox').combobox()
    fix_autocomplete()
$(document).ready(ready)

$(document).on 'click','.add_fields', (event) ->
  time = new Date().getTime()
  regexp = new RegExp($(this).data('id'),'g')
  $(this).before($(this).data('fields').replace(regexp,time))
#  $(this).closest('.box-body').find('.remove-particular').css('visibility','visible')
  event.preventDefault()
  debugger;
  $('select.combobox').combobox()
  fix_autocomplete()
  manage_cheque_all_select()

manage_cheque = ($this) ->
  $val = $this.val()
  $parent_row = $this.parent().parent()
  $cheque = $parent_row.find('.cheque')

  if ($this.find("option[value="+$val+"]").text().indexOf('Bank:') == 0)
    callback = (response) ->
      if parseInt(response) != 0
        $cheque.val(response)
      else
        $cheque.val("")

    $this.parent().parent().find('.cheque-container').show()
    if ($cheque.hasClass('cr') || ($parent_row.find('.type-selector select').val() == 'cr'))
      $this.parent().parent().find('.cheque-container.bank').hide()
      $.get '/cheque_entries/get_cheque_number/', {bank_account_id: $val}, callback, 'json'


  else
    $cheque.val("")
    $this.parent().parent().find('.cheque-container').hide()


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
#      if ($this.find('.voucher_particulars_amnt input').val().trim() == "" || parseFloat($this.find('.voucher_particulars_amnt input').val()) == 0)
#        $this.remove()


    $("select.select-ledger").each ->
      $this = $(this)
      $val = $val = $this.val()
      if ($this.find("option[value="+$val+"]").text().indexOf('Bank:') == 0)
        $input = $this.parent().parent().find('input.cheque')
        if($input.val().trim().length == 0)
          $input.parent().addClass('has-error')
          $input.parent().append('<p class="error">Cheque cant be empty</p>')
          event.preventDefault()
        else
          $input.parent().removeClass('has-error')
          $input.parent().find('p.error').hide()


$ ->
  $('form').on 'click', '.removeThisParticular', (event) ->
    $(this).closest('div.row.particular').remove()
    event.preventDefault()