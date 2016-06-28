# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

selectedTransactionMessagesIdsForEmail = []
selectedTransactionMessagesIdsForSMS= []

$(document).ready ->
  if $('#transaction_message_list').length > 0
    console.log("doc loaded!")

    $(document).on 'change', 'input:checkbox', (event)->
      selectedTransactionMessagesIdsForEmail = `$("#filterrific_results .email:input:checkbox:checked").not('.email#select_all, .sms#select_all').map(function(){return this.id}).get();`
      selectedTransactionMessagesIdsForSMS = `$("#filterrific_results .sms:input:checkbox:checked").not('.email#select_all, .sms#select_all').map(function(){return this.id}).get();`
      console.log selectedTransactionMessagesIdsForEmail 
      console.log selectedTransactionMessagesIdsForSMS
      
    $(document). on 'click', '.email#select_all', (event) ->
      $(".email:input:checkbox").not('.cant-email').prop('checked', $(this).prop("checked"))
      $(".email:input:checkbox").not('.cant-email').attr('disabled', false)

    $(document). on 'click', '.sms#select_all', (event) ->
      $(".sms:input:checkbox").not('.cant-sms').prop('checked', $(this).prop("checked"))
      $(".sms:input:checkbox").not('.cant-sms').attr('disabled', false)
      
    $(document). on 'click', '#send-sms', (event) ->
      console.log "send sms clicked!"
      params = {transaction_message_ids: selectedTransactionMessagesIdsForSMS}
      $.ajax
        url: '/transaction_messages/send_sms'
        type: 'post'
        data: params
        dataType: 'json'
        beforeSend: ->
          console.log 'Ajax Initiated!'
          $('#send-sms-spinner').removeClass 'hidden'
        error: (jqXHR, textStatus, errorThrown) ->
          console.log 'There was some error!' + errorThrown + textStatus
          $('#send-sms-spinner').addClass 'hidden'
        success: (data, textStatus, jqXHR) ->
          console.log 'Ajax Completed!'
          $('#send-sms-spinner').addClass 'hidden'
          return
      
    $(document). on 'click', '#send-email', (event) ->
      params = {transaction_message_ids: selectedTransactionMessagesIdsForEmail}
      $.ajax
        url: '/transaction_messages/send_email'
        type: 'post'
        data: params
        dataType: 'json'
        beforeSend: ->
          console.log 'Ajax Initiated!'
          $('#send-email-spinner').removeClass 'hidden'
        error: (jqXHR, textStatus, errorThrown) ->
          console.log 'There was some error!' + errorThrown + textStatus
          $('#send-email-spinner').addClass 'hidden'
        success: (data, textStatus, jqXHR) ->
          console.log 'Ajax Completed!'
          $('#send-email-spinner').addClass 'hidden'
          return


      