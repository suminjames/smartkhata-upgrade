# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

selectedTransactionMessagesIdsForEmail = []
selectedTransactionMessagesIdsForSMS= []
allTransactionMessagesIds = []

transactionMessagesStatusesPoller = undefined

clearTransactionMessagesStatusesPoller = ->
  if $('#transaction_message_list').length = 0
    clearInterval transactionMessagesStatusesPoller
    $(document).off 'page:change', clearTransactionMessagesStatusesPoller


#$(document).on 'page:change', -> 
#  clearTransactionMessagesStatusesPoller 
  
$(document).on 'page:change', ->
  if $('#transaction_message_list').length > 0
    console.log("doc loaded!")
    
    # Store all transaction messages' ids in the DOM(window) right now.
    allTransactionMessagesIds = `$("#filterrific_results .email:input:checkbox").not('.email#select_all, .sms#select_all').map(function(){return this.id}).get();`

    # Poll for transaction messages' email and sms status every 4 seconds
    transactionMessagesStatusesPoller = setInterval pollForTransactionMessagesStatuses , 4000
    $(document).on 'page:change', clearTransactionMessagesStatusesPoller
    
    $(document).on 'change', 'input:checkbox', (event)->
      selectedTransactionMessagesIdsForEmail = `$("#filterrific_results .email:input:checkbox:checked").not('.email#select_all, .sms#select_all').map(function(){return this.id}).get();`
      selectedTransactionMessagesIdsForSMS = `$("#filterrific_results .sms:input:checkbox:checked").not('.email#select_all, .sms#select_all').map(function(){return this.id}).get();`
#      console.log selectedTransactionMessagesIdsForEmail 
#      console.log selectedTransactionMessagesIdsForSMS
      
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


$ ->
  $('[data-toggle="tooltip"]').tooltip()
  return

pollForTransactionMessagesStatuses = ->
#  console.log allTransactionMessagesIds
  params = {transaction_message_ids: allTransactionMessagesIds}
  $.ajax
    url: '/transaction_messages/sent_status'
    type: 'post'
    data: params
    dataType: 'json'
    beforeSend: ->
      console.log 'Ajax Initiated!'
    error: (jqXHR, textStatus, errorThrown) ->
      console.log 'There was some error!' + errorThrown + textStatus
    success: (data, textStatus, jqXHR) ->
#      console.log data
      reflectStatusChanges data
      return

reflectStatusChanges = (data) ->
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
    emailStatusStr = 'Queued' + '(' + sentEmailCount + ')'
  else if emailStatus == 'email_sent'
    sentEmailCount = transactionMessage.sent_email_count
    emailStatusStr = 'Yes' + '(' + sentEmailCount + ')'
  $("#email_status_" + transactionMessage.id).html(emailStatusStr)

# change the sms sent status (and sms count if sent)
updateSmsStatus = (transactionMessage) ->
  smsStatus =  transactionMessage.sms_status
  smsStatusStr = ''
  if smsStatus == 'sms_unsent'
    smsStatusStr = 'No'
  else if smsStatus == 'sms_queued'
    sentSmsCount = transactionMessage.sent_sms_count
    smsStatusStr = 'Queued' + '(' + sentSmsCount + ')'
  else if smsStatus == 'sms_sent'
    sentSmsCount = transactionMessage.sent_sms_count
    smsStatusStr = 'Yes' + '(' + sentSmsCount + ')'
  $("#sms_status_" + transactionMessage.id).html(smsStatusStr)
