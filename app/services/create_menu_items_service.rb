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
      menu_list['menus'].each do |menu|
        params = {name: menu['name'], path: menu['path'], hide_on_main_navigation: menu['hide_on_main_navigation']}

        menu_item = MenuItem.new(params)
        sub_menu_list = menu['sub_menus'] || []
        sub_menu_list.each do |sub_menu|
          params = {name: sub_menu['name'], path: sub_menu['path'], hide_on_main_navigation: sub_menu['hide_on_main_navigation']}
          sub_menu_item = MenuItem.new(params)
          menu_item.children << sub_menu_item

          inner_menu_list = sub_menu['menu_items'] || []
          inner_menu_list.each do |menu_item|
            params = {name: menu_item['name'], path: menu_item['path'], hide_on_main_navigation: menu_item['hide_on_main_navigation']}
            _menu_item = MenuItem.new(params)
            sub_menu_item.children << _menu_item
          end
        end
        menu_item.save!
      end
    end


    Apartment::Tenant.switch!('public')


    #
    # modify the has_changes key to false
    # previous menu_list object contains compiled values
    # so the yaml is loaded again to preserve its original form
    #

    menu_list = YAML::load_file(menu_list_file)
    menu_list['has_changes'] = false
    File.open(menu_list_file, 'w') do |h|
      h.write menu_list.to_yaml
    end

    true
  end
end