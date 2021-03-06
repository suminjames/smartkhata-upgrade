@get_num_val = (val) ->
  if isNaN(val)
    return 0.00
  return val

@parse_number = (data) ->
  return get_num_val(Number($(data).text().replace(/,/g, '')))

@parse_number_from_string = (data) ->
  return get_num_val(Number(data.replace(/,/g, '')))

@format_number = (data) ->
  return data.toFixed(2).replace(/(\d)(?=(\d{3})+\.)/g, "$1,")

@round_number = (data) ->
  return parseFloat(data).toFixed(2)

@positive_currency_raw = (data) ->
  return Math.abs(round_number(data))

@number_to_currency = (data) ->
  return format_number(Math.abs(data))

#$ ->
#  $(".ledger-group").each ->
#    opening_balance_dr = 0
#    opening_balance_cr = 0
#    dr_amount = 0
#    cr_amount = 0
#    closing_balance_dr = 0
#    closing_balance_cr = 0
#
#    $this = $(this)
#    ledgers_list = $this.find('.ledger-single')
#    for ledger in ledgers_list
#      data = $(ledger).find('td')
#      opening_balance_dr += parse_number(data[1])
#      opening_balance_cr += parse_number(data[2])
#      dr_amount += parse_number(data[3])
#      cr_amount += parse_number(data[4])
#      closing_balance_dr += parse_number(data[5])
#
#      closing_balance_cr += parse_number(data[6])
#
#    dr_amount = format_number(dr_amount)
#    cr_amount = format_number(cr_amount)
#
##    if (opening_balance_dr >= opening_balance_cr)
##      opening_balance_dr = opening_balance_dr - opening_balance_cr
##      opening_balance_cr = 0
##    else
##      opening_balance_cr = opening_balance_cr - opening_balance_dr
##      opening_balance_dr = 0
##
##    if (closing_balance_dr >= closing_balance_cr)
##      closing_balance_dr = closing_balance_dr - closing_balance_cr
##      closing_balance_cr = 0
##    else
##      closing_balance_cr = closing_balance_cr - closing_balance_dr
##      closing_balance_dr = 0
#
#    opening_balance_dr = format_number(opening_balance_dr)
#    opening_balance_cr = format_number(opening_balance_cr)
#    closing_balance_dr = format_number(closing_balance_dr)
#    closing_balance_cr = format_number(closing_balance_cr)
#
#
#    $this.append('<tr class="total-trial"><td>Total</td><td class="text-right">' + opening_balance_dr + '</td><td class="text-right">' + opening_balance_cr + '</td><td class="text-right">' + dr_amount + '</td><td class="text-right">' + cr_amount + '</td><td class="text-right">' + closing_balance_dr + '</td><td class="text-right">' + closing_balance_cr + '</td></tr>')
#
##    for the grand total section
#  opening_balance_dr = 0
#  opening_balance_cr = 0
#  dr_amount = 0
#  cr_amount = 0
#  closing_balance_dr = 0
#  closing_balance_cr = 0
#
#  $('.total-trial').each ->
#    data = $(this).find('td')
#    opening_balance_dr += parse_number(data[1])
#    opening_balance_cr += parse_number(data[2])
#    dr_amount += parse_number(data[3])
#    cr_amount += parse_number(data[4])
#    closing_balance_dr += parse_number(data[5])
#    closing_balance_cr += parse_number(data[6])
#
#  dr_amount = format_number(dr_amount)
#  cr_amount = format_number(cr_amount)
#
##  if (opening_balance_dr >= opening_balance_cr)
##    opening_balance_dr = opening_balance_dr - opening_balance_cr
##    opening_balance_cr = 0
##  else
##    opening_balance_cr = opening_balance_cr - opening_balance_dr
##    opening_balance_dr = 0
#
##  if (closing_balance_dr >= closing_balance_cr)
##    closing_balance_dr = closing_balance_dr - closing_balance_cr
##    closing_balance_cr = 0
##  else
##    closing_balance_cr = closing_balance_cr - closing_balance_dr
##    closing_balance_dr = 0
#
#  opening_balance_dr = format_number(opening_balance_dr)
#  opening_balance_cr = format_number(opening_balance_cr)
#  closing_balance_dr = format_number(closing_balance_dr)
#  closing_balance_cr = format_number(closing_balance_cr)
#
#  $('.end').append('<td>Grand Total</td><td class="text-right">' + opening_balance_dr + '</td><td class="text-right">' + opening_balance_cr + '</td><td class="text-right">' + dr_amount + '</td><td class="text-right">' + cr_amount + '</td><td class="text-right">' + closing_balance_dr + '</td><td class="text-right">' + closing_balance_cr + '</td>')