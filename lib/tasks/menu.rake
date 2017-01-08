namespace :menu do
  desc "Update the menu for the application"
  task :update_list => :environment do
    puts "Successfully updated menu." if MenuItemService.new.call
  end

  task :remove_list => :environment do
    puts "Successfully deleted menu." if MenuItemService.new.delete_all
  end
end
