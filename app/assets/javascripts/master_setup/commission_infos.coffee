# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->
  $('form').on 'click', '.removeThisDetail', (event) ->

    $(this).closest('div.row.commission-detail').remove()
    event.preventDefault()