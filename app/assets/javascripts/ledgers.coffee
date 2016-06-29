# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document) . on 'click', '.z-selectable #select_all', (event) ->
  $("input:checkbox.check-ledger").prop('checked', $(this).prop("checked"))
  update_balance_text()


get_ledger_balance = ($this) ->
  $parent = $this.closest('tr')
  if $parent.hasClass('dr')
    return parse_number($parent.find('.display-amount'))
  else
    return parse_number($parent.find('.display-amount')) * -1

get_total_ledger_balance = () ->
  balance = 0
  $('.z-selectable .check-ledger:checked').each ->
    balance += get_ledger_balance($(this))
  return balance

update_balance_text = () ->
  ledger_amount = get_total_ledger_balance()
  $total_amount = $('.total-ledger-amount .display-amount')
  $total_type = $('.total-ledger-amount .display-type')

  $total_amount.text(format_number(Math.abs(ledger_amount)))
  $total_type.text(if ledger_amount >= 0 then 'dr' else 'cr')

$ ->
  $(document).on 'change', '.z-selectable .check-ledger', (event) ->
    $this = $(this)
    update_balance_text()