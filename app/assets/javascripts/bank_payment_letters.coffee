# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
# code to select required menus

get_balance = ($this) ->
  $parent = $this.closest('tr')
  if $parent.hasClass('dr')
    return parse_number($parent.find('.bill-amount'))
  else
    return parse_number($parent.find('.bill-amount')) * -1

get_total_balance = () ->
  balance = 0
  $('.check-bill:checked').each ->
    balance += get_balance($(this))
  return balance

$(document).ready ->
  $(document) . on 'click', '.selectable-table .select_all', (event) ->
    $this  = $(this)
    $this.closest('table')
    .find("td input[type='checkbox']")
    .not(".no-bank-account")
    .prop('checked', this.checked)

    bill_amount = get_total_balance()
    $total_amount = $('.total-bill-amount .display-amount')
    $total_amount.text(format_number(Math.abs(bill_amount)))