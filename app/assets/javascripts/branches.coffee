# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# Display tickmark when the color of the box matches
displayTickMark = (colorCode) ->
  $('#recommended_colors').children('div').each ->
    if $(this).attr('data-color') == colorCode
      $(this).find("span").removeClass("hidden")
    else
      $(this).find("span").addClass("hidden")

$(document).on 'ready page:load', ->
  colorPicker = $('[data-toggle="colorpicker"]')

  #setting the color values of boxes from the data attribute
  $('#recommended_colors').children('div').each ->
     $(this).css('backgroundColor', $(this).attr('data-color'))

  colorPicker.minicolors({theme: 'bootstrap',format:'rgb', opacity: true});
  colorCode = colorPicker.minicolors("value")
  displayTickMark(colorCode)

  $(".color-box-clickable").click ->
    newColorCode = $(this).attr('data-color')
    colorPicker.minicolors("value", newColorCode)

  $("#branch_top_nav_bar_color").on 'change', ->
    changedColorCode =  colorPicker.minicolors("value")
    $('.navbar').css('backgroundColor', changedColorCode)
    displayTickMark(changedColorCode)


