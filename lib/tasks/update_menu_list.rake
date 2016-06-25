desc "Update the menu for the application"
task :update_menu_list => :environment do
  puts "successfully updated" if CreateMenuItemsService.new.call
end