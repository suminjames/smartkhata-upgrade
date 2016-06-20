# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

selectedTransactionMessagesIds = []

$(document).ready ->
  if $('#transaction_message_list').length > 0
    console.log("doc loaded!")

    $(document).on 'change', 'input:checkbox', (event)->
      selectedTransactionMessagesIds = `$("#filterrific_results input:checkbox:checked").not('#select_all').map(function(){return this.id}).get();`
      
    $(document). on 'click', '#select_all', (event) ->
      $("input:checkbox").prop('checked', $(this).prop("checked"))
      $("input:checkbox").attr('disabled', false);

    $(document). on 'click', '#send-sms', (event) ->
      console.log "send sms clicked!"
      params = {transaction_message_ids: selectedTransactionMessagesIds}
      $.ajax
        url: '/transaction_messages/send_sms'
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
      
    $(document). on 'click', '#send-email', (event) ->
      params = {transaction_message_ids: selectedTransactionMessagesIds}
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
          
    $(document). on 'click', '#send-sms-and-email', (event) ->
      console.log "send sms and email clicked!"


      