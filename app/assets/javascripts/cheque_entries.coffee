# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

selectedChequeEntriesIds= []
allChequeEntriesIds= []

$(document).on 'page:change', ->
  if $('#cheque_entry_list').length > 0
    console.log("doc loaded!")

    # Store all cheque entries' ids in the DOM(window) right now.
    allChequeEntriesIds = `$("#filterrific_results .cheque-entry:input:checkbox").not('.cheque-entry#select_all').not('.cheque-entry.unassigned-cheque').map(function(){return this.id}).get();`
    allChequeEntriesIds = allChequeEntriesIds.sort()

    $(document).on 'change', 'input:checkbox', (event)->
      selectedChequeEntriesIds = `$("#filterrific_results .cheque-entry:input:checkbox:checked").not('.cheque-entry#select_all').not('.cheque-entry.unassigned-cheque').map(function(){return this.id}).get();`
      # The dom is parsed top to bottom, hence, the selectedChequeEntriesIds maintain a sort order.
      # However, sort to (double) make sure they are sorted to ensure cheques maintain serial-ness while printing.
      selectedChequeEntriesIds = selectedChequeEntriesIds.sort()
      setButtonsActivenesses()
      console.log selectedChequeEntriesIds

    $(document).on 'click', '.cheque-entry#select_all', (event) ->
      console.log 'all'
      $(".cheque-entry:input:checkbox").not('.cheque-entry.unassigned-cheque').prop('checked', $(this).prop("checked"))
      $(".cheque-entry:input:checkbox").not('.cheque-entry.unassigned-cheque').attr('disabled', false)

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
            settlement_ids_arr = data.settlement_ids || []
            settlement_ids_arg = $.param({settlement_ids: settlement_ids_arr})
            loadAndPrint("/settlements/show_multiple.pdf?" + settlement_ids_arg, 'iframe-for-settlements-pdf-print', 'settlements-print-spinner');
            return


    $(document).on 'click', ".btnPrintChequeEntriesPDF", (event) ->
      if selectedChequeEntriesIds.length > 0
        cheque_entries_ids_argument = $.param({cheque_entry_ids: selectedChequeEntriesIds})
        loadAndPrintChequeEntries("/cheque_entries/show_multiple.pdf?" + cheque_entries_ids_argument, 'iframe-for-cheque-entries-pdf-print', 'cheque-entries-print-spinner')
        event.stopImmediatePropagation()

    reflectPrintStatusChange = (chequeEntries) ->
      for chequeEntry in chequeEntries
        id = chequeEntry.id
        print_status = chequeEntry.print_status
        if print_status == 1
          $("#cheque_entry_" + id + " .print-status").html("Printed")
          $("#cheque_entry_" + id).removeClass('cheque-entry-not-printed').addClass('cheque-entry-printed')
        setButtonsActivenesses()

    setButtonsActivenesses= ->
      toggleAllButtons()
      setSelectAllCheckboxSelection()
      setPrintChequeEntriesButtonActiveness()
      setViewChequeEntriesButtonActiveness()
      setPrintBillsAndSettlementsAssociatedWithChequesButtonActiveness()

    toggleAllButtons = ->
      if isAnyChequeSelected()
        $('.btnPrintPDF').removeClass 'btn-disabled'
      else
        $('.btnPrintPDF').addClass 'btn-disabled'

    setPrintChequeEntriesButtonActiveness = ->
      target = $('.btnPrintChequeEntriesPDF')
      if isAnyUnprintableChequeSelected()
        target.addClass 'btn-disabled'
        $('.receipt-cheque-selected-warning').show()
      else
        $('.receipt-cheque-selected-warning').hide()

    setViewChequeEntriesButtonActiveness = ->
      target = $('.btnViewChequeEntriesPDF')
      if isAnyUnprintableChequeSelected()
        target.addClass 'btn-disabled'
        $('.receipt-cheque-selected-warning').show()
      else
        $('.receipt-cheque-selected-warning').hide()

    setPrintBillsAndSettlementsAssociatedWithChequesButtonActiveness = ->
      target1 = $('.btnPrintBillsAssociatedWithChequesPDF')
      target2 = $('.btnPrintSettlementsAssociatedWithChequesPDF')
      if isAnyUnassignedChequeSelected()
        target1.addClass 'btn-disabled'
        target2.addClass 'btn-disabled'
        $('.receipt-cheque-selected-warning').show()
      else
        $('.receipt-cheque-selected-warning').hide()

    setSelectAllCheckboxSelection = ->
      isSelected = arraysEqual(selectedChequeEntriesIds, allChequeEntriesIds)
      $('.cheque-entry#select_all').prop('checked', isSelected)

    isAnyChequeSelected = ->
      return selectedChequeEntriesIds.length > 0

    isAnyUnprintableChequeSelected = ->
      atLeastOnceIsSelectedOfClass '.cheque-entry.unprintable-cheque'

    isAnyReceiptChequeSelected = ->
      atLeastOnceIsSelectedOfClass '.cheque-entry.receipt-cheque'

    isAnyUnassignedChequeSelected = ->
      atLeastOnceIsSelectedOfClass '.cheque-entry.unassigned-cheque'

    # Checks to see if atleast one of checkboxes  with the passed in klass(es) is checked/selected.
    # params klass - string with class(es). Eg. '.class-a' or '.class-x.class-y'
    atLeastOnceIsSelectedOfClass = (klass) ->
      atleastOneIsSelected = false
      $(klass).each ->
        if $(this).hasClass('unassigned') == false
          if $(this).is(':checked')
            atleastOneIsSelected = true
            # Stop .each from processing any more items
            return false
          return
      return atleastOneIsSelected


    # The following functions print and callPrint has been excerpted from https://www.sitepoint.com/load-pdf-iframe-call-print/
    # Similar functions also available in application.js but due to the nested ajax-ish complexity for cheque printing followed by cheque print status updating (in both backend and frontend), the function here has been renamed and modified.

    # Fetches contents to be printed in an iframe
    loadAndPrintChequeEntries = (url, iframeId, spinnerId) ->
      $('#' + spinnerId).removeClass 'hidden'
      # console.log("load and print");
      _this = this
      $iframe = $('iframe#' + iframeId)
      $iframe.attr 'src', url
      $iframe.load ->
        callPrintChequeEntries iframeId, spinnerId
        return
      return

    # Initiates print once content has been loaded into iframe
    callPrintChequeEntries = (iframeId, spinnerId) ->
    # console.log("call print");
      PDF = document.getElementById(iframeId)
      PDF.focus()
      PDF.contentWindow.print()
      $('#' + spinnerId).addClass('hidden')
      updatePrintStatus()
      return


    # Updates(in database) and reflects(in DOM) the 'printed' status via ajax.
    updatePrintStatus = ->
      console.log 'Update Print Status'
      cheque_entries_ids_argument = $.param({cheque_entry_ids: selectedChequeEntriesIds})
      $.ajax
        url: '/cheque_entries/update_print_status'
        data: cheque_entries_ids_argument
        dataType: 'json'
        error: (jqXHR, textStatus, errorThrown) ->
          console.log("There was some error!")
        success: (data, textStatus, jqXHR) ->
          reflectPrintStatusChange(data.cheque_entries)
          return
