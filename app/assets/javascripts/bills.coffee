# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
get_balance =($this) ->
  $parent = $this.closest('tr')
  if $parent.hasClass('dr')
    return parse_number($parent.find('.bill-amount'))
  else
    return parse_number($parent.find('.bill-amount')) * -1

sum_bill_balance = (bill_amount, total_bill_amount, increment) ->
  increment ||= false

  if increment
    total_bill_amount += bill_amount
  else
    total_bill_amount -= bill_amount

$ ->
  $(document).on 'change','.check-bill', (event) ->

    $this = $(this)

    if ($this.is(':checked'))
      debugger
      bill_amount = get_balance($this)
      $total_amount = $('.total-bill-amount .display-amount')
      $total_type = $('.total-bill-amount .display-type')
      total_bill_amount = parse_number($total_amount)
      $newTotal = sum_bill_balance(bill_amount,total_bill_amount, true)
      $total_amount.text(format_number(Math.abs($newTotal)))
      $total_type.text(if $newTotal >= 0 then 'dr' else 'cr')
    else
      bill_amount = get_balance($this)
      $total_amount = $('.total-bill-amount .display-amount')
      $total_type = $('.total-bill-amount .display-type')
      total_bill_amount = parse_number($total_amount)
      $newTotal = sum_bill_balance(bill_amount,total_bill_amount)
      $total_amount.text(format_number(Math.abs($newTotal)))
      $total_type.text(if $newTotal >= 0 then 'dr' else 'cr')