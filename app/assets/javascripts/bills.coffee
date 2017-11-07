# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
get_balance = ($this) ->
  $parent = $this.closest('tr')
  if $parent.hasClass('dr')
    return parse_number($parent.find('.bill-amount'))
  else
    return parse_number($parent.find('.bill-amount')) * -1

get_bill_id = ($this) ->
  $parent = $this.closest('tr')
  return $parent.find('td.formatted-bill-number').text()

get_bill_names = () ->
  arr = []
  $('.check-bill:checked').each ->
    arr.push(get_bill_id($(this)))
  return arr.join(',')

get_bill_ids = () ->
  arr = []
  $('.check-bill:checked').each ->
    arr.push($(this).val())
  return arr.join(',')

get_total_balance = () ->
  balance = 0
  $('.check-bill:checked').each ->
    balance += get_balance($(this))
  return balance

$ ->
  $(document).on 'change', '.check-bill', (event) ->
    $this = $(this)
    bill_amount = get_total_balance()
    $total_amount = $('.total-bill-amount .display-amount')
    $total_type = $('.total-bill-amount .display-type')

    $total_amount.text(format_number(Math.abs(bill_amount)))
    $total_type.text(if bill_amount >= 0 then 'dr' else 'cr')

    $('.total-bill-amount .numeric-amount').text(bill_amount)
    $('.total-bill-amount .selected-bill-name-list').text(get_bill_names())
    $('.total-bill-amount .selected-bill-id-list').text(get_bill_ids())

selectedBillsIds= []
allBillsIds= []

$(document).on 'change', 'input:checkbox', (event)->
  selectedBillsIds = `$("#filterrific_results .bill:input:checkbox:checked").not('.bill#select_all').map(function(){return this.id}).get();`
  setButtonsActivenesses()
  console.log selectedBillsIds

$(document).on 'click', '.bill#select_all', (event) ->
  console.log 'all'
  $(".bill:input:checkbox").prop('checked', $(this).prop("checked"))
  $(".bill:input:checkbox").attr('disabled', false)

$(document).off('click', '.download-selected_bill').on 'click', ".download-selected_bill", (event) ->
  bills_ids_argument = $.param({bill_ids: selectedBillsIds})
  window.open("/bills/show_multiple.pdf?" + bills_ids_argument, '_blank')

setButtonsActivenesses= ->
  toggleAllButtons()

toggleAllButtons = ->
    if isAnyBillSelected()
      $('.download-selected_bill').removeClass 'btn-disabled'
    else
      $('.download-selected_bill').addClass 'btn-disabled'

isAnyBillSelected = ->
  return selectedBillsIds.length > 0
