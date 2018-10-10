def select_helper(value,id)
  page.execute_script(%Q($("select##{id}").select2('open')))
  page.execute_script(%Q($(".select2-search__field").val("#{value}")))
  page.execute_script(%Q($(".select2-search__field").trigger('keyup')))
  sleep(1)
  page.execute_script(%Q($('.select2-results__option--highlighted').trigger('mouseup')))
end
