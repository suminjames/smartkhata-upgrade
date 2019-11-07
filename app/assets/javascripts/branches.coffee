# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# Display tickmark when the color of the box matches
displayTickMark = (colorCode) ->
  $('#recommended_colors').children('div').each ->
    if $(this).css('backgroundColor') == colorCode
      $(this).find("span").removeClass("hidden")
    else
      $(this).find("span").addClass("hidden")

$(document).on 'ready page:load', ->
  colorPicker = $('[data-toggle="colorpicker"]')

  colorPicker.minicolors({theme: 'bootstrap'});
  colorCode = colorPicker.minicolors("value")
  displayTickMark(colorCode)

  $(".color-box-clickable").click ->
    newColorCode = $(this).css('backgroundColor');
    colorPicker.minicolors("value", newColorCode)

  $("#branch_top_nav_bar_color").on 'change', ->
    changedColorCode =  colorPicker.minicolors("value")
    $('.navbar').css('backgroundColor', changedColorCode)
    displayTickMark(changedColorCode)



# to return background color as hex values directly as opposed to rgb values
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

