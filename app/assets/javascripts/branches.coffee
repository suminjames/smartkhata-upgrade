# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/



$(document).on 'ready page:load', ->
  colorCode =  $('[data-toggle="colorpicker"]').minicolors("value")
  $(".color-box-clickable").click ->
    $(".color-box-clickable").not(this).find("span").addClass("hidden");
    $(this).find("span").toggleClass("hidden");
    newColorCode = $(this).css('backgroundColor');
    $('[data-toggle="colorpicker"]').minicolors("value", newColorCode)

  $("#branch_top_nav_bar_color").on 'change', ->
    changedColorCode =  $('[data-toggle="colorpicker"]').minicolors("value")
    $('.navbar').css('backgroundColor', changedColorCode)



# to return background color as hex values directly
$.cssHooks.backgroundColor = get: (elem) ->
  `var bg`

  hex = (x) ->
    ('0' + parseInt(x).toString(16)).slice -2

  if elem.currentStyle
    bg = elem.currentStyle['backgroundColor']
  else if window.getComputedStyle
    bg = document.defaultView.getComputedStyle(elem, null).getPropertyValue('background-color')
  if bg.search('rgb') == -1
    bg
  else
    bg = bg.match(/^rgb\((\d+),\s*(\d+),\s*(\d+)\)$/)
    '#' + hex(bg[1]) + hex(bg[2]) + hex(bg[3])

