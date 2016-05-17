# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  $(document).on 'click','#btnPrintCheque', (event) ->
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