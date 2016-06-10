# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
get_balance =($this) ->
  $parent = $this.closest('tr')
  if $parent.hasClass('dr')
    return parse_number($parent.find('.bill-amount'))
  else
    return parse_number($parent.find('.bill-amount')) * -1

get_total_balance = () ->
  debugger
  balance = 0
  $('.check-bill:checked').each ->
    balance += get_balance($(this))
  return balance

$ ->
  $(document).on 'change','.check-bill', (event) ->

    $this = $(this)
    debugger
    bill_amount = get_total_balance()
    $total_amount = $('.total-bill-amount .display-amount')
    $total_type = $('.total-bill-amount .display-type')

    $total_amount.text(format_number(Math.abs(bill_amount)))
    $total_type.text(if bill_amount >= 0 then 'dr' else 'cr')