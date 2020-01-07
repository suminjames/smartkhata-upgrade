def select_helper(value,id)
  page.execute_script(%Q($("select##{id}").select2('open')))
  page.execute_script(%Q($(".select2-search__field").val("#{value}")))
  page.execute_script(%Q($(".select2-search__field").trigger('keyup')))
  sleep(1)
  page.execute_script(%Q($('.select2-results__option--highlighted').trigger('mouseup')))
end

def company_info
  expect(page).to have_content('Danphe')
  expect(page).to have_content('Kupondole')
  expect(page).to have_content('Phone: 99999')
  expect(page).to have_content('Fax: 0989')
  expect(page).to have_content('PAN: 9909')
end

 def user_activity
   expect(page).to have_content('Prepared By')
   expect(page).to have_content('Approved By')
   expect(page).to have_content('Received By')
 end

