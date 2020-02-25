# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/



fix_autocomplete = () ->
  $('.combobox-container input:text').each ->
    $(this).attr('autocomplete', 'off')

get_url =() ->
  path = location.pathname;
  path = path.split('/');
  url = [location.origin, path[1], path[2]].join('/')
  return url

$.fn.extend
  skDisable: ->
    @each ->
      $(this).prop('disabled', true);
      $(this).find('option').attr("selected",false)
  skEnable: ->
    @each ->
      $(this).prop('disabled', false);
  skInitializeSelect2Simple: ->
    @each ->
      $(this).select2({
        theme: "bootstrap",
        selectOnClose: true
      })
  skInitializeSelect2Ledger: ->
    url = get_url() + '/ledgers/combobox_ajax_filter'
    @each ->
      `$(this).select2({
          theme: 'bootstrap',
          allowClear: true,
          minimumInputLength: 3,
          ajax: {
              url: url,
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

particular_has_bank = ($this) ->
  $val = $this.val()
  $this.find("option[value='" + $val + "']").text().indexOf('Bank:') == 0

#  cheque and bank input enable and disable on the basis of selections
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
    $this.parent().parent().find('.cheque-container input').skEnable()
    $this.parent().parent().find('.cheque-container.bank select').skEnable()
    if ($cheque.hasClass('cr') || ($parent_row.find('.type-selector select').val() == 'cr'))
      $this.parent().parent().find('.cheque-container.bank select').skDisable()
      $.get get_url() + '/cheque_entries/get_cheque_number/', {bank_account_id: $val}, callback, 'json'
    else
      if clear_cheque
        $cheque.val("")
  else
    $cheque.val("")
    $this.parent().parent().find('.cheque-container input').skDisable()
    $this.parent().parent().find('.cheque-container.bank select').skDisable()


manage_bill_finder = ($this) ->
  $ledger_id = $this.val()
  $particular = $this.closest('.particular')
  $billFinder = $this.closest('.particular').find('a.bill-finder')
  $particular.find('.particular-bill-container .info').text('')
  $particular.find('.particular-bill-container input').val('')

  if $billFinder != undefined
    href = $billFinder.attr('href')
    if href != undefined
      $billFinder.attr('href', href.replace(/ledger_id=[^&]+/, 'ledger_id='+ $ledger_id));

#    all particular wide fix
manage_cheque_all_select = () ->
  $("select.select-ledger").each ->
    $this = $(this)
    manage_cheque($this)


error_populate_cheque_number = ($this) ->
  if particular_has_bank($this) && !is_payment_bank_transfer()
    $input = $this.parent().parent().find('input.cheque')
    if($input.val().trim().length == 0)
      if !$input.parent().hasClass('has-error')
        $input.parent().addClass('has-error')
        $input.parent().append('<p class="error">Enter Cheque</p>')
      event.preventDefault()
    else
      $input.parent().removeClass('has-error')
      $input.parent().find('p.error').hide()

# Check for addtional bank selection only for receipt voucher with bank
error_populate_additional_bank_select= ($this) ->
  if particular_has_bank($this) && !is_payment_bank_transfer()
    # Check if additional bank field is available, which should only be true for receipt voucher with bank.
    is_additional_bank_field_present = $this.parent().parent().find('.cheque-container.bank').size() != 0
    # Also, in JVR, selection of Dr or Cr  for bank ledgers changes disablity of additional bank select tag. Accomodate this too.
    is_additional_bank_field_visible = $this.parent().parent().find('.cheque-container.bank').is(":enabled")
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

display_balance_total = ($this) ->
  $voucher_element = $this.closest('.voucher .box .box-body')
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

$(document).ready(ready)
#  on selecting a transaction type it has to do some changes based on whether its a bank or not and dr or cr
$ ->
  $(document).on 'change', '.type-selector select', (event) ->
    $ledgerSelect = $(this).closest('.particular').find('select.select-ledger')
    manage_cheque($ledgerSelect, true)

# initially check all the ledger and enable the cheque only when it is needed
$ ->
  manage_cheque_all_select()

#  error population in case of cheque number
#  for the cases where cheque number is required
$ ->
  $(document).on 'change', '.cheque', (event) ->
    $ledgerSelect = $(this).closest('.particular').find('select.select-ledger')
    error_populate_cheque_number($ledgerSelect)

#    check and display error when cheque container is not selected
$ ->
  $(document).on 'change', '.cheque-container.bank', (event) ->
    $ledgerSelect = $(this).closest('.particular').find('select.select-ledger')
    error_populate_additional_bank_select($ledgerSelect)

#    actions based on the ledger selection
$ ->
  $(document).on 'change', 'select.select-ledger', (event) ->
    $this = $(this)
    manage_cheque($this)
    manage_bill_finder($this)



$ ->
  $('#new_voucher').on 'submit', (event) ->
    $("select.select-ledger").each ->
      $this = $(this)
      error_populate_cheque_number($this)
      error_populate_additional_bank_select($this)

$ ->
  $('form').on 'click', '.removeThisParticular', (event) ->

    $(this).closest('div.particular-container').remove()
    event.preventDefault()



$(document).on 'click', '.add_fields', (event) ->
  time = new Date().getTime()
  regexp = new RegExp($(this).data('id'), 'g')
  id = $('.dynamic-ledgers').children('.particular-container').length
  $(this).before($(this).data('fields').replace(regexp, id))

#  new_particular_row_is_financial_ledger = $(this).data('fields').includes('voucher-financial-ledger-combobox')

  $('select.select2simple').skInitializeSelect2Simple()
  $('select.select2-ajax-ledger').skInitializeSelect2Ledger()

#  #  Addition of particular row is different in receipt voucher, where the Credit Particulars should only be financial ledgers. Check for type of particular adding, and act accordingly.
#  if new_particular_row_is_financial_ledger == true
#  #    id_of_new_particular_row_ledger_select = "voucher-financial-ledger-combobox"
#  #    $('select.combobox#' + id_of_new_particular_row_ledger_select).select2({
#  #      theme: "bootstrap",
#  #      selectOnClose: true
#  #    })
#  else
##    id_of_new_particular_row_ledger_select = "voucher_particulars_attributes_" + time + "_ledger_id"
#    # bind combobox ajax to newly added generic particular row
##    bind_ajax_to_new_particular_row(id_of_new_particular_row_ledger_select)

  event.preventDefault()
  fix_autocomplete()
  manage_cheque_all_select()


$(document).on 'change', '.voucher_particulars_amount input', (event) ->
  display_balance_total($(this))

$(document).on 'change', '.type-selector select', (event) ->
  display_balance_total($(this))





$ ->
  $settlement_type = $('input:radio[name="voucher_settlement_type"]:checked')
  manage_group_vendor_entry($settlement_type)


  $('input:radio[name="voucher_settlement_type"]').on 'change', (event) ->
    manage_group_vendor_entry($(this))


  $('input:radio[name="payment_mode"]').on 'change', (event) ->
    manage_cheque_all_select()

$(document).on 'click', '.add-to-caller', (event) ->
  $this = $(this)
  skId = $this.data('id')
  $particular = $($('div[data-particular="'+skId+'"]')[0])
  $modal = $this.closest('#smartkhata-modal')
  $amount = parseFloat($modal.find('.numeric-amount').text())
  $bill_list = $modal.find('.selected-bill-name-list').text()
  $bill_ids = $modal.find('.selected-bill-id-list').text()
  $error = false
  $message = "Please Proceed with Payment voucher to continue this action"
#  make sure it is not a negative amount

  if ( $particular.find('.type-selector select').val() == 'dr' )
    if ($amount > 0 )
      $error = true
      $message = "Please Proceed with Receipt voucher to continue this action"
    else
      $amount = Math.abs($amount)

  if ($amount <= 0 || $error == true)
    alert($message)
    $particular.find('.voucher_particulars_amount input').val(0)
    $particular.find('.particular-bill-container .info').text('')
    $particular.find('.particular-bill-container .selected-bill-names input').val("")
    $particular.find('.particular-bill-container .selected-bill-ids input').val("")
  else
    $particular.find('.voucher_particulars_amount input').val($amount)
    $particular.find('.particular-bill-container .info').text($bill_list)
    $particular.find('.particular-bill-container .selected-bill-names input').val($bill_list)
    $particular.find('.particular-bill-container .selected-bill-ids input').val($bill_ids)
    $modal.modal('hide')

  display_balance_total($particular)

$(document).on 'click', '.narration-display', (event) ->
 $this =  $(this)
 $narration = $this.closest('.particular-narration')
 $this.addClass("hidden")
 $narration.find('input').removeClass("hidden")
