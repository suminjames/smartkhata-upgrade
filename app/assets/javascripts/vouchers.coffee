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
      selectOnClose: true,
      allowClear: true,
    })
    $('select.combobox.min-3').select2({
      theme: "bootstrap",
      selectOnClose: true,
      allowClear: true,
      minimumInputLength: 3,
    })
    $('select.combobox#voucher-financial-ledger-combobox').select2({
      theme: "bootstrap",
      selectOnClose: true,
    })

    fix_autocomplete()

is_payment_bank_transfer = () ->
  _payment_mode = $('input:radio[name="payment_mode"]:checked')
  if _payment_mode.val() == 'bank_transfer'
    return true
  return false

$(document).ready(ready)


particular_has_bank = ($this) ->
  $val = $this.val()
  $this.find("option[value='" + $val + "']").text().indexOf('Bank:') == 0

manage_cheque = ($this, clear_cheque) ->
  clear_cheque ||= false
  $val = $this.val()
  $parent_row = $this.parent().parent()
  $cheque = $parent_row.find('.cheque')
  if particular_has_bank($this) && !is_payment_bank_transfer()
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
  if particular_has_bank($this) && !is_payment_bank_transfer()
    $input = $this.parent().parent().find('input.cheque')
    if($input.val().trim().length == 0)
      if !$input.parent().hasClass('has-error')
        $input.parent().addClass('has-error')
        $input.parent().append('<p class="error">Cheque cant be empty</p>')
      event.preventDefault()
    else
      $input.parent().removeClass('has-error')
      $input.parent().find('p.error').hide()

# Check for addtional bank selection only for receipt voucher with bank
error_populate_additional_bank_select= ($this) ->
  if particular_has_bank($this) && !is_payment_bank_transfer()
    # Check if additional bank field is available, which should only be true for receipt voucher with bank.
    is_additional_bank_field_present = $this.parent().parent().find('.cheque-container.bank').size() != 0
    # Also, in JVR, selection of Dr or Cr  for bank ledgers changes visibility of additional bank select tag. Accomodate this too.
    is_additional_bank_field_visible = $this.parent().parent().find('.cheque-container.bank').is(":visible")
    if is_additional_bank_field_present == true && is_additional_bank_field_visible == true
      $select = $this.parent().parent().find('.cheque-container.bank').find('select')
      # check if additional bank is selected or not
      # unselected select option will have val of ''
      if($.isNumeric($select.val()) == false)
        if !$select.parent().hasClass('has-error')
          $select.parent().addClass('has-error')
          $select.parent().append('<p class="error">Bank must be selected</p>')
        event.preventDefault()
      else
        $select.parent().removeClass('has-error')
        $select.parent().find('p.error').hide()

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
  $(document).on 'change', '.cheque-container.bank', (event) ->
    $ledgerSelect = $(this).closest('.particular').find('select.select-ledger')
    error_populate_additional_bank_select($ledgerSelect)

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
      error_populate_additional_bank_select($this)


$ ->
  $('form').on 'click', '.removeThisParticular', (event) ->

    $(this).closest('div.row.particular').remove()
    event.preventDefault()

bind_ajax_to_new_particular_row = (id_of_new_particular_row) ->
  `$("#" + id_of_new_particular_row).select2({
      theme: 'bootstrap',
      allowClear: true,
      minimumInputLength: 3,
      ajax: {
          url: "/ledgers/combobox_ajax_filter",
          dataType: 'json',
          delay: 250,
          data: function (params) {
              return {
                  q: params.term, // search term
                  search_type: 'generic'// search type
              };
          },
          processResults: function (data, params) {
              return {
                  results: data
              };
          }
      }
  });`

$(document).on 'click', '.add_fields', (event) ->
  time = new Date().getTime()
  regexp = new RegExp($(this).data('id'), 'g')
  $(this).before($(this).data('fields').replace(regexp, time))

  new_particular_row_is_financial_ledger = $(this).data('fields').includes('voucher-financial-ledger-combobox')
  #  Addition of particular row is different in receipt voucher, where the Credit Particulars should only be financial ledgers. Check for type of particular adding, and act accordingly.
  if new_particular_row_is_financial_ledger == true
    id_of_new_particular_row_ledger_select = "voucher-financial-ledger-combobox"
    id_of_new_particular_row_additional_bank_select = "voucher_particulars_attributes_" + time + "_additional_bank_id"
    $('select.combobox#' + id_of_new_particular_row_ledger_select).select2({
      theme: "bootstrap",
      selectOnClose: true
    })
    $('select.combobox#' + id_of_new_particular_row_additional_bank_select).select2({
      theme: "bootstrap",
      selectOnClose: true
    })
  else
    id_of_new_particular_row_ledger_select = "voucher_particulars_attributes_" + time + "_ledger_id"
    # bind combobox ajax to newly added generic particular row
    bind_ajax_to_new_particular_row(id_of_new_particular_row_ledger_select)

  event.preventDefault()
  fix_autocomplete()
  manage_cheque_all_select()


$(document).on 'change', '.voucher_particulars_amount input', (event) ->
  display_balance_total($(this))

$(document).on 'change', '.type-selector select', (event) ->
  display_balance_total($(this))


display_balance_total = ($this) ->
  $voucher_element = $this.closest('.voucher .box .box-body')
  total_block = $voucher_element.find('.total-display')
  if total_block.length < 1
    $voucher_element.append("<br/></br><div class='total-display'></div>")
    total_block = $voucher_element.find('.total-display')

  cr_amount = 0
  dr_amount = 0
  $voucher_element.find('.row.particular').each ->
    amount = parse_number_from_string($(this).find('.voucher_particulars_amount input').val())
    if $(this).find('.type-selector select').val() == 'cr'
      cr_amount += amount
    else
      dr_amount += amount
  total_block.html('Debit:' + Math.round(dr_amount * 100) / 100 + ' Credit: ' + Math.round(cr_amount * 100)/ 100 + ' Difference :' + Math.round((Math.abs(dr_amount - cr_amount)) * 100) / 100 )

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