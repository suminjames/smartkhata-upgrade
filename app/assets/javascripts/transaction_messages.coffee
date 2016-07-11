# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

selectedTransactionMessagesIdsForEmail = []
selectedTransactionMessagesIdsForSMS= []
allTransactionMessagesIds = []

transactionMessagesStatusesPoller = undefined

# Issue with turbolinks and setInterval is circumvented using idea from https://product.reverb.com/2015/04/09/fun-with-setinterval-and-turbolinks/
clearTransactionMessagesStatusesPoller = ->
  clearInterval transactionMessagesStatusesPoller
  $(document).off 'page:change', clearTransactionMessagesStatusesPoller


#$(document).on 'page:change', -> 
#  clearTransactionMessagesStatusesPoller 
  
$(document).on 'page:change', ->
  if $('#transaction_message_list').length > 0
    console.log("doc loaded!")
    
    # Store all transaction messages' ids in the DOM(window) right now.
    allTransactionMessagesIds = `$("#filterrific_results .email:input:checkbox").not('.email#select_all, .sms#select_all').map(function(){return this.id}).get();`

    # Poll for transaction messages' email and sms status every x seconds
#    transactionMessagesStatusesPoller = setInterval pollForTransactionMessagesStatuses , 1000
    $(document).on 'page:change', clearTransactionMessagesStatusesPoller
    
    $(document).on 'change', 'input:checkbox', (event)->
      selectedTransactionMessagesIdsForEmail = `$("#filterrific_results .email:input:checkbox:checked").not('.email#select_all, .sms#select_all').map(function(){return this.id}).get();`
      selectedTransactionMessagesIdsForSMS = `$("#filterrific_results .sms:input:checkbox:checked").not('.email#select_all, .sms#select_all').map(function(){return this.id}).get();`
#      console.log selectedTransactionMessagesIdsForEmail 
#      console.log selectedTransactionMessagesIdsForSMS

    $(document). on 'click', '.refresh-icon', (event) ->
      window.location.reload(true)
    
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
          console.log 'Send SMS Ajax Initiated!'
          $('#send-sms').prop 'disabled', true
          $('#send-sms').attr 'value', 'Sending SMS...'
          $('#send-sms-spinner').removeClass 'hidden'
        error: (jqXHR, textStatus, errorThrown) ->
          $('#send-sms').prop 'disabled', false
          $('#send-sms').attr 'value', 'Send SMS'
          console.log 'Send SMS Ajax Error!'
          console.log 'There was some error!' + errorThrown + textStatus
          $('#send-sms-spinner').addClass 'hidden'
        success: (data, textStatus, jqXHR) ->
          console.log 'Send SMS Ajax Success!'
          $('#send-sms').prop 'disabled', false
          $('#send-sms').attr 'value', 'Send SMS'
          pollForTransactionMessagesStatuses()
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
          console.log 'Send Email Ajax Initiated!'
          $('#send-email').prop 'disabled', true
          $('#send-email').attr 'value', 'Sending Email...'
          $('#send-email-spinner').removeClass 'hidden'
        error: (jqXHR, textStatus, errorThrown) ->
          $('#send-email').prop 'disabled', false
          $('#send-email').attr 'value', 'Send Email'
          console.log 'Send Mail Ajax Error!'
          console.log 'There was some error!' + errorThrown + textStatus
          $('#send-email-spinner').addClass 'hidden'
        success: (data, textStatus, jqXHR) ->
          console.log 'Send Email Ajax Success!'
          $('.email-queued-warning').show()
          pollForTransactionMessagesStatuses()
          $('#send-email').prop 'disabled', false
          $('#send-email').attr 'value', 'Send Email'
          $('#send-email-spinner').addClass 'hidden'
          return

    pollForTransactionMessagesStatuses = () ->
      params = {transaction_message_ids: allTransactionMessagesIds}
      $.ajax
        url: '/transaction_messages/sent_status'
        type: 'post'
        data: params
        dataType: 'json'
        beforeSend: ->
          console.log 'Polling for transaction messages status initiated!'
        error: (jqXHR, textStatus, errorThrown) ->
          console.log 'Error in Polling for transaction messages status'
          console.log 'There was some error!' + errorThrown + textStatus
        success: (data, textStatus, jqXHR) ->
          console.log 'Polling for transaction messages status success!'
          reflectStatusChanges data
          return

    reflectStatusChanges = (data) ->
      console.log 'Message statuses changed.'
      transactionMessages = data
      for transactionMessage in transactionMessages
        updateEmailStatus(transactionMessage)
        updateSmsStatus(transactionMessage)


    # change the email sent status (and email count if sent)
    updateEmailStatus = (transactionMessage) ->
      emailStatus =  transactionMessage.email_status
      emailStatusStr = ''
      if emailStatus == 'email_unsent'
        emailStatusStr = 'No'
      else if emailStatus == 'email_queued'
        sentEmailCount = transactionMessage.sent_email_count
        emailStatusStr = 'Queued' + "<br>" + "<div class='light-text'>" + "count:" + sentEmailCount + '</div >'
      else if emailStatus == 'email_sent'
        sentEmailCount = transactionMessage.sent_email_count
        emailStatusStr = 'Yes' + "<br>" + "<div class='light-text'>" + "count:" + sentEmailCount + '</div >'
      $("#email_status_" + transactionMessage.id).html(emailStatusStr)

    # change the sms sent status (and sms count if sent)
    updateSmsStatus = (transactionMessage) ->
      smsStatus =  transactionMessage.sms_status
      smsStatusStr = ''
      if smsStatus == 'sms_unsent'
        smsStatusStr = 'No'
      else if smsStatus == 'sms_queued'
        sentSmsCount = transactionMessage.sent_sms_count
        smsStatusStr = 'Queued' + "<br>" + "<div class='light-text'>" + "count:" + sentSmsCount + '</div >'
      else if smsStatus == 'sms_sent'
        sentSmsCount = transactionMessage.sent_sms_count
        smsStatusStr = 'Yes' + "<br>" + "<div class='light-text'>" + "count:" + sentSmsCount + '</div >'
      $("#sms_status_" + transactionMessage.id).html(smsStatusStr)


$ ->
  $('[data-toggle="tooltip"]').tooltip()
  return

