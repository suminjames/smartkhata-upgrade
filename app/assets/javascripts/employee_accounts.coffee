# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

existingAssociationsLedgerIds = []
currentlySelectedAssociationLedgerIds = []

hideUnhideWarning = ->
  if `$('#employee_account_has_access_to_everyone').is(':checked') === true`
    $('.everyone-selected-warning').show()
  else
    $('.everyone-selected-warning').hide()

updateSelection = ->
  currentlySelectedAssociationLedgerIds = `$("input:checkbox:checked").not('#select_all').map(function () {
      return this.value
  }).get();`

isCurrentSelectionSameAsInitial = ->
# Comparing two array for equivalence using code from http://stackoverflow.com/questions/1773069/using-jquery-to-compare-two-arrays-of-javascript-objects
  return (`$(currentlySelectedAssociationLedgerIds).not(existingAssociationsLedgerIds).length === 0 && $(existingAssociationsLedgerIds).not(currentlySelectedAssociationLedgerIds).length === 0`)

setSubmitButtonActiveness = ->
  hideUnhideWarning()
  updateSelection()
  if isCurrentSelectionSameAsInitial() is false and currentlySelectedAssociationLedgerIds.length isnt 0
    `$('input[type="submit"]').prop('disabled', false)`
  else if isCurrentSelectionSameAsInitial() is false and `$('#employee_account_has_access_to_nobody').is(':checked') === true`
    `$('input[type="submit"]').prop('disabled', false)`
  else
    `$('input[type="submit"]').prop('disabled', true)`

$(document).ready ->
  if $('#edit_employee_ledger_association').length > 0
    console.log("doc loaded!")
    # Capture (from dom) and store all associated ledgers' ids after the dom is fully loaded
    existingAssociationsLedgerIds = `$("input:checkbox:checked").not('#select_all').map(function () {
        return this.value
    }).get();`

    $(document).on 'change', 'input:radio, input:checkbox', (event)->
      setSubmitButtonActiveness()

    $(document) . on 'click', '#employee_account_has_access_to_everyone', (event) ->
      $("input:checkbox").not('#select_all').prop('checked', "checked")
      $("input:checkbox").attr('disabled', true);

    $(document) . on 'click', '#employee_account_has_access_to_some', (event) ->
      $("input:checkbox").prop('checked', "");
      $('input:checkbox[value=' + ledgerId + ']').not('#select_all').prop 'checked', 'checked' for ledgerId in existingAssociationsLedgerIds
      $("input:checkbox").attr('disabled', false);

    $(document) . on 'click', '#employee_account_has_access_to_nobody', (event) ->
      $("input:checkbox").prop('checked', "");
      $("input:checkbox").attr('disabled', true);

    $(document) . on 'click', '#select_all', (event) ->
      $("input:checkbox").prop('checked', $(this).prop("checked"))
      $("input:checkbox").attr('disabled', false);


# code to select required menus
$(document).ready ->
  $(document) . on 'click', '.menu-permission-list .select_all', (event) ->
    $this  = $(this)
    $this.siblings('ul')
      .find("input[type='checkbox']")
      .prop('checked', this.checked)