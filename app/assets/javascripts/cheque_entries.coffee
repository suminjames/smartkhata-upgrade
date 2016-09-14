# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

selectedChequeEntriesIds= []

$(document).on 'page:change', ->
  if $('#cheque_entry_list').length > 0
    console.log("doc loaded!")
    
    $(document).on 'change', 'input:checkbox', (event)->
      selectedChequeEntriesIds = `$("#filterrific_results .cheque-entry:input:checkbox:checked").not('.cheque-entry#select_all').map(function(){return this.id}).get();`
      # The dom is parsed top to bottom, hence, the selectedChequeEntriesIds maintain a sort order.
      # However, sort to (double) make sure they are sorted to ensure cheques maintain serial-ness while printing.
      selectedChequeEntriesIds = selectedChequeEntriesIds.sort()
      console.log selectedChequeEntriesIds

    $(document).on 'click', '.cheque-entry#select_all', (event) ->
      console.log 'all'
      $(".cheque-entry:input:checkbox").not('.cant-print-cheque').prop('checked', $(this).prop("checked"))
      $(".cheque-entry:input:checkbox").not('.cant-print-cheque').attr('disabled', false)

    $(document).on 'click', ".btnViewChequeEntriesPDF", (event) ->
      cheque_entries_ids_argument = $.param({cheque_entry_ids: selectedChequeEntriesIds})
      window.open("/cheque_entries/show_multiple.pdf?" + cheque_entries_ids_argument, '_blank')

    $(document).on 'click', ".btnPrintBillsAssociatedWithChequesPDF" , (event) ->
      if selectedChequeEntriesIds.length > 0
        cheque_entries_ids_argument = $.param({cheque_entry_ids: selectedChequeEntriesIds})
        event.stopImmediatePropagation()
        $.ajax
          url: '/cheque_entries/bills_associated_with_cheque_entries'
          data: cheque_entries_ids_argument
          dataType: 'json'
          error: (jqXHR, textStatus, errorThrown) ->
            console.log("There was some error!")
          success: (data, textStatus, jqXHR) ->
            console.log("Ajax Success!")
            associated_bill_ids = data.bill_ids || []
            bill_ids_arg = $.param({bill_ids: associated_bill_ids})
            loadAndPrint('/bills/show_multiple.pdf?' + bill_ids_arg, 'iframe-for-bill-pdf-print', 'bills-print-spinner')
            return

    $(document).on 'click', ".btnPrintSettlementsAssociatedWithChequesPDF" , (event) ->
      if selectedChequeEntriesIds.length > 0
        cheque_entries_ids_argument = $.param({cheque_entry_ids: selectedChequeEntriesIds})
        event.stopImmediatePropagation()
        $.ajax
          url: '/cheque_entries/settlements_associated_with_cheque_entries'
          data: cheque_entries_ids_argument
          dataType: 'json'
          error: (jqXHR, textStatus, errorThrown) ->
            console.log("There was some error!")
          success: (data, textStatus, jqXHR) ->
            console.log("Ajax Success!")
            console.log("MAjax Success!")
            settlement_ids_arr = data.settlement_ids || []
            settlement_ids_arg = $.param({settlement_ids: settlement_ids_arr})
            loadAndPrint("/settlements/show_multiple.pdf?" + settlement_ids_arg, 'iframe-for-settlements-pdf-print', 'settlements-print-spinner');
            return


    $(document).on 'click', ".btnPrintChequeEntriesPDF", (event) ->
      if selectedChequeEntriesIds.length > 0
        cheque_entries_ids_argument = $.param({cheque_entry_ids: selectedChequeEntriesIds})
        event.stopImmediatePropagation()
        $.ajax
          url: '/cheque_entries/update_print_status'
          data: cheque_entries_ids_argument
          dataType: 'json'
          error: (jqXHR, textStatus, errorThrown) ->
            console.log("There was some error!")
          success: (data, textStatus, jqXHR) ->
            reflectPrintStatusChange(data.cheque_entries)
            loadAndPrint("/cheque_entries/show_multiple.pdf?" + cheque_entries_ids_argument, 'iframe-for-cheque-entries-pdf-print', 'cheque-entries-print-spinner')
            return


    reflectPrintStatusChange = (chequeEntries) ->
      for chequeEntry in chequeEntries
        id = chequeEntry.id
        print_status = chequeEntry.print_status
        $("#cheque_entry_" + id + " .print-status").html("Printed") if print_status == 1

# PseudoCode overview:
# if can_print? || is_receipt?
#   enable checkbox
# printCheque
#   print can_print only
# printAssociatedBills, printAssociatedSettlements
#   print can_print and also receipt
