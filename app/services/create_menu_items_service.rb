class CreateMenuItemsService
  include Rails.application.routes.url_helpers

  def call
    menu_list_file = Rails.root.join('config', 'smartkhata', 'menu.yml')
    menu_list = YAML::load(ERB.new(File.read(menu_list_file)).result(binding))

    # if menu_list['has_changes'] != true
    #   return false
    # end

    tenants = Tenant.all
    tenants.each do |t|
      Apartment::Tenant.switch!(t.name)
      begin
        menu_list['menus'].each do |menu|
          params = {name: menu['name'], code: menu['code'], path: menu['path'], hide_on_main_navigation: menu['hide_on_main_navigation'], request_type: menu['request_type']}
          menu_item = MenuItem.create(params)
          menu['menu_item_id'] = menu_item.id
          sub_menu_list = menu['sub_menus'] || []
          sub_menu_list.each do |sub_menu|
            params = {name: sub_menu['name'], code: sub_menu['code'], path: sub_menu['path'], hide_on_main_navigation: sub_menu['hide_on_main_navigation'], request_type: menu['request_type']}
            puts sub_menu['name']
            sub_menu_item = MenuItem.create(params)
            sub_menu['menu_item_id'] = sub_menu_item.id
            menu_item.children << sub_menu_item

            inner_menu_list = sub_menu['menu_items'] || []
            inner_menu_list.each do |menu_item|
              params = {name: menu_item['name'], code: menu_item['code'], path: menu_item['path'], hide_on_main_navigation: menu_item['hide_on_main_navigation'], request_type: menu['request_type']}
              _menu_item = MenuItem.create(params)
              menu_item['menu_item_id'] = _menu_item.id
              sub_menu_item.children << _menu_item
            end
          end
          menu_item.save!

        end
      rescue
        puts 'ad'
      end

      # store the database id for each of the tenant menu items
      File.open(Rails.root.join('config', 'smartkhata', 'tenant_menus', "#{t.name}_menu.yml"), 'w') do |h|
        h.puts "#"
        h.puts "# available action/menus"
        h.puts "# documentation available at menu.yml"
        h.puts "#"
        h.write menu_list.to_yaml
      end
    end

    # keeping the menu.yml file intact
    Apartment::Tenant.switch!('public')
    menu_list = YAML::load_file(menu_list_file)
    menu_list['has_changes'] = false
    File.open(menu_list_file, 'w') do |h|
      h.puts "#"
      h.puts "# available action/menus"
      h.puts "# default request_type is get"
      h.puts "#"
      h.write menu_list.to_yaml
    end

    true
  end
end