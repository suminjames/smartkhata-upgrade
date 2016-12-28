namespace :menu do
  desc "Update the menu for the application"
  task :update_list => :environment do
    puts "successfully updated" if MenuItemService.new.call
  end

  task :remove_list => :environment do
    puts "successfully deleted" if MenuItemService.new.delete_all
  end
end
