# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  $(document).on 'click', '#btnPrintCheque', (event) ->
    event.stopImmediatePropagation();
    $this = $(this)
    $.ajax
      url: "/cheque_entries/update_print"
      data:
        cheque_id: $this.data('cheque-id')
      dataType: "json"
      error: (jqXHR, textStatus, errorThrown) ->
        $this.find('cheque-print-error').html('There was some Errror')
      success: (data, textStatus, jqXHR) ->

#        if data.message.trim() != ""
#          $this.find('.cheque-print-error').html(data['message'])
#        else
        printElement($('.printThis')[0])
        window.print()


        
selectedChequeEntriesIds= []
allChequeEntriesIds= []


$(document).on 'page:change', ->
  if $('#cheque_entry_list').length > 0
    console.log("doc loaded!")
    
    # Store all cheque entries' ids in the DOM(window) right now.
    allChequeEntriesIds = `$("#filterrific_results .cheque-entry:input:checkbox").not('.cheque-entry#select_all').map(function(){return this.id}).get();`

    $(document).on 'change', 'input:checkbox', (event)->
      selectedChequeEntriesIds = `$("#filterrific_results .cheque-entry:input:checkbox:checked").not('.cheque-entry#select_all').map(function(){return this.id}).get();`
      console.log selectedChequeEntriesIds

    $(document).on 'click', '.cheque-entry#select_all', (event) ->
      console.log 'all'
      $(".cheque-entry:input:checkbox").not('.cant-print').prop('checked', $(this).prop("checked"))
      $(".cheque-entry:input:checkbox").not('.cant-print').attr('disabled', false)

    $(document).on 'click', ".btnViewChequeEntriesPDF", (event) ->
      cheque_entries_ids_argument = $.param({cheque_entry_ids: selectedChequeEntriesIds})
      window.open("/cheque_entries/show_multiple.pdf?" + cheque_entries_ids_argument, '_blank')
      
    $(document).on 'click', ".btnPrintChequeEntriesPDF", (event) ->
      cheque_entries_ids_argument = $.param({cheque_entry_ids: selectedChequeEntriesIds})
      loadAndPrint("/cheque_entries/show_multiple.pdf?" + cheque_entries_ids_argument, 'iframe-for-cheque-entries-pdf-print', 'cheque-entries-print-spinner');
    
