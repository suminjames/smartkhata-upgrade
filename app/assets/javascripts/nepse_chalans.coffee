# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$(document).ready ->
  $(document). on 'click', '.nepse-chalan #select_all', (event) ->
    $("input:checkbox").prop('checked', $(this).prop("checked"))
    $("input:checkbox").attr('disabled', false);

    $('input:checkbox[name="nepse_share_selection[]"]').each ->
      $parent_row = $(this).closest('tr')
      if ($(this).prop("checked"))
        $parent_row.addClass('checked')
      else
        $parent_row.removeClass('checked')

  $(document).on 'click', '.display-chalan-desc', (event) ->
    event.preventDefault()
    $parent = $(this).parent()
    all_selected_transaction = $('tr.checked td.trans-number')

    if all_selected_transaction.length < 1
      if !$parent.hasClass('has-error')
        $parent.addClass('has-error')
        $parent.append('<p class="error">Please Select at least one Transaction</p>')
        return false
      else
        $parent.removeClass('has-error')
        $parent.find('p.error').hide()






    $('.share_transactions_list.nepse-chalan').hide()
    $('.nepse-chalan-description').show()
    desc = ""
    net_amount = 0.0
    all_selected_transaction = $('tr.checked td.trans-number')
    all_selected_amount = $('tr.checked td.bank-deposit')
    for data in all_selected_amount
      net_amount += parse_number(data)

    first_trans = all_selected_transaction.first().text()
    last_trans = all_selected_transaction.last().text()
    desc = "Settlement by Bank Transfer for Transaction numbers "
    if first_trans == last_trans
      desc = desc + first_trans
    else
      desc = desc + first_trans + '-' + last_trans

    $('.nepse-chalan-description .description').html(desc)
    net_amount = format_number(net_amount)
    $('.nepse-chalan-description .net-amount').html(net_amount)
    
  $(document).on 'click', '.cancel-chalan-desc', (event) ->
    event.preventDefault()
    $('.share_transactions_list.nepse-chalan').show()
    $('.nepse-chalan-description').hide()


  $('input:checkbox[name="nepse_share_selection[]"]').on 'change', (event) ->
    $parent_row = $(this).closest('tr')
    if (this.checked)
      $parent_row.addClass('checked')
    else
      $parent_row.removeClass('checked')


  $('#new_nepse_chalan').on 'submit', (event) ->
    $input = $('input.select-ledger')
    $comboboxContainer = $input.closest('.combobox-container')
    if $input.val().trim() == ""
      if !$comboboxContainer.hasClass('has-error')
        $comboboxContainer.addClass('has-error')
        $comboboxContainer.append('<p class="error">Bank Account cant be empty</p>')
      event.preventDefault()
    else
      $comboboxContainer.removeClass('has-error')
      $comboboxContainer.find('p.error').hide()
      
    $input_settlement = $('.settlement-id')
    $settlement_parent = $input_settlement.closest('.row')

    if $input_settlement.val().trim() == ""
      if !$settlement_parent.hasClass('has-error')
        $settlement_parent.addClass('has-error')
        $settlement_parent.append('<p class="error">Settlement Id cant be empty</p>')
      event.preventDefault()
    else
      $settlement_parent.removeClass('has-error')
      $settlement_parent.find('p.error').hide()