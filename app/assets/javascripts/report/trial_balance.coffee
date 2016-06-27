@get_num_val = (val) ->
  if isNaN(val)
    return 0.00
  return val

@parse_number = (data) ->
  console.log($(data).text().replace(',', ''))
  return get_num_val(Number($(data).text().replace(/,/g, '')))

@format_number = (data) ->
  return data.toFixed(2).replace(/(\d)(?=(\d{3})+\.)/g, "$1,")

$ ->
  $(".ledger-group").each ->
    opening_blnc_dr = 0
    opening_blnc_cr = 0
    dr_amount = 0
    cr_amount = 0
    closing_blnc_dr = 0
    closing_blnc_cr = 0

    $this = $(this)
    ledgers_list = $this.find('.ledger-single')
    for ledger in ledgers_list
      data = $(ledger).find('td')
      opening_blnc_dr += parse_number(data[1])
      opening_blnc_cr += parse_number(data[2])
      dr_amount += parse_number(data[3])
      cr_amount += parse_number(data[4])
      closing_blnc_dr += parse_number(data[5])
      closing_blnc_cr += parse_number(data[6])


    dr_amount = format_number(dr_amount)
    cr_amount = format_number(cr_amount)
    if (opening_blnc_dr >= opening_blnc_cr)
      opening_blnc_dr = opening_blnc_dr - opening_blnc_cr
      opening_blnc_cr = 0
    else
      opening_blnc_cr = opening_blnc_cr - opening_blnc_dr
      opening_blnc_dr = 0

    if (closing_blnc_dr >= closing_blnc_cr)
      closing_blnc_dr = closing_blnc_dr - closing_blnc_cr
      closing_blnc_cr = 0
    else
      closing_blnc_cr = closing_blnc_cr - closing_blnc_dr
      closing_blnc_dr = 0

    opening_blnc_dr = format_number(opening_blnc_dr)
    opening_blnc_cr = format_number(opening_blnc_cr)
    closing_blnc_dr = format_number(closing_blnc_dr)
    closing_blnc_cr = format_number(closing_blnc_cr)


    $this.append('<tr class="total-trial"><td>Total</td><td class="text-right">' + opening_blnc_dr + '</td><td class="text-right">' + opening_blnc_cr + '</td><td class="text-right">' + dr_amount + '</td><td class="text-right">' + cr_amount + '</td><td class="text-right">' + closing_blnc_dr + '</td><td class="text-right">' + closing_blnc_cr + '</td></tr>')