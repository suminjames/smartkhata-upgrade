# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

manage_cheque_all_select = () ->
  $("select.select-ledger").each ->
    $this = $(this)
    manage_cheque($this)

fix_autocomplete = () ->
  $('.combobox-container input:text').each ->
    $(this).attr('autocomplete', 'off')

ready = ->
  jQuery ->
    $('select.combobox').select2({
      theme: "bootstrap",
      selectOnClose: true
    })
    fix_autocomplete()

is_payment_bank_transfer = () ->
  _payment_mode = $('input:radio[name="payment_mode"]:checked')
  if _payment_mode.val() == 'bank_transfer'
    return true
  return false

$(document).ready(ready)



manage_cheque = ($this, clear_cheque) ->
  clear_cheque ||= false
  $val = $this.val()
  $parent_row = $this.parent().parent()
  $cheque = $parent_row.find('.cheque')

  if ($this.find("option[value=" + $val + "]").text().indexOf('Bank:') == 0) && !is_payment_bank_transfer()
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
      if clear_cheque
        $cheque.val("")

  else
    $cheque.val("")
    $this.parent().parent().find('.cheque-container').hide()

error_populate_cheque_number = ($this) ->
  $val = $val = $this.val()
  if ($this.find("option[value=" + $val + "]").text().indexOf('Bank:') == 0) && !is_payment_bank_transfer()
    $input = $this.parent().parent().find('input.cheque')
    if($input.val().trim().length == 0)
      if !$input.parent().hasClass('has-error')
        $input.parent().addClass('has-error')
        $input.parent().append('<p class="error">Cheque cant be empty</p>')
      event.preventDefault()
    else
      $input.parent().removeClass('has-error')
      $input.parent().find('p.error').hide()

$ ->
  $(document).on 'change', '.type-selector select', (event) ->
    $ledgerSelect = $(this).closest('.particular').find('select.select-ledger')
    manage_cheque($ledgerSelect, true)

$ ->
  manage_cheque_all_select()

$ ->
  $(document).on 'change', '.cheque', (event) ->
    $ledgerSelect = $(this).closest('.particular').find('select.select-ledger')
    error_populate_cheque_number($ledgerSelect)

$ ->
  $(document).on 'change', 'select.select-ledger', (event) ->
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
      error_populate_cheque_number($this)


$ ->
  $('form').on 'click', '.removeThisParticular', (event) ->
    $(this).closest('div.row.particular').remove()
    event.preventDefault()

$(document).on 'click', '.add_fields', (event) ->
  time = new Date().getTime()
  regexp = new RegExp($(this).data('id'), 'g')
  $(this).before($(this).data('fields').replace(regexp, time))
  #  $(this).closest('.box-body').find('.remove-particular').css('visibility','visible')
  event.preventDefault()
  $('select.combobox').select2({
    theme: "bootstrap",
    selectOnClose: true
  })
  $('.filterrific-select.min-3').select2({
    theme: 'bootstrap',
    tags: true,
    allowClear: true,
    minimumInputLength: 3
  })

  fix_autocomplete()
  manage_cheque_all_select()


#  show hide sections based on selection
manage_group_vendor_entry = ($this) ->
  if ($this.val() == 'default')
    $('.many-to-single-settlement-client').hide()
    $('.many-to-single-settlement-vendor').hide()
  else if ($this.val() == 'vendor')
    $('.many-to-single-settlement-client').hide()
    $('.many-to-single-settlement-vendor').show()
  else
    $('.many-to-single-settlement-vendor').hide()
    $('.many-to-single-settlement-client').show()


$ ->
  $settlement_type = $('input:radio[name="voucher_settlement_type"]:checked')
  manage_group_vendor_entry($settlement_type)


  $('input:radio[name="voucher_settlement_type"]').on 'change', (event) ->
    manage_group_vendor_entry($(this))


  $('input:radio[name="payment_mode"]').on 'change', (event) ->
    manage_cheque_all_select()