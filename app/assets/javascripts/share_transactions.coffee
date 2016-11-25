# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# TODO: Deleting the following code after consulting Subas.
# $ ->
#   total_in = 0
#   total_out = 0
#   $('.quantity-in').each ->
#     number = parseInt($(this).text())
#     total_in +=  number if !isNaN(number)
#   $('.quantity-out').each ->
#     number = parseInt($(this).text())
#     total_out += number if !isNaN(number)
#   $('.total-show').html('<td colspan=3>Total</td><td>'+total_in+'</td>'+'<td>'+total_out+'</td>')

# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

selectedShareTransactionIds= []

$(document).on 'page:change', ->
  if $('#share_transaction_list.items-to-act-container').length > 0
    $(document).on 'change', '.share_transaction input:checkbox', (event)->
      toggleActionButtons()

    $(document).on 'click', '.share_transaction#select_all', (event) ->
      $(".share_transaction input:checkbox").prop('checked', $(this).prop("checked"))
      toggleActionButtons()

    $(document).on 'click', ".btnMarkCloseout" , (event) ->
      if selectedShareTransactionIds.length > 0

        make_processed = $(this).hasClass('processed') ? true : false

        share_transaction_ids_argument = $.param({share_transaction_ids: selectedShareTransactionIds, make_processed: make_processed})
        event.stopImmediatePropagation()
        spinnerId = 'closeout-mark-processed'
        $.ajax
          url: '/share_transactions/make_closeouts_processed'
          data: share_transaction_ids_argument
          dataType: 'json'
          beforeSend: () ->
            $('#' + spinnerId).removeClass('hidden')
          error: (jqXHR, textStatus, errorThrown) ->
            console.log("There was some error!")
          success: (data, textStatus, jqXHR) ->
            reflectStatusChange(data.share_transactions)
            return
          complete: () ->
            $('#' + spinnerId).addClass('hidden')

    toggleActionButtons = ->
      selectedShareTransactionIds = `$("#filterrific_results .share_transaction :input:checkbox:checked").not('.share_transaction#select_all').map(function(){return this.id}).get();`
      if isAnySettlementSelected()
        $('.action').removeClass 'btn-disabled'
      else
        $('.action').addClass 'btn-disabled'

    reflectStatusChange = (share_transactions) ->
      for share_transaction in share_transactions
        id = share_transaction.id
        closeout_status = share_transaction.closeout_settled
        if closeout_status == true
          $("#share_transaction_" + id).removeClass('indicator-bg-light-red')
          $('#'+id).prop('checked', false)
        else if  closeout_status == false
          $("#share_transaction_" + id).addClass('indicator-bg-light-red')
          $('#'+id).prop('checked', false)
      $('.share_transaction#select_all').prop("checked", false)

    isAnySettlementSelected = ->
      return selectedShareTransactionIds.length > 0