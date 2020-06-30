
class MenuItemService
  include Rails.application.routes.url_helpers

  def find_or_create_by_code(params)
    menu_item = MenuItem.find_by(code: params[:code])
    if menu_item.present?
      menu_item.assign_attributes(params)
    else
      menu_item = MenuItem.create(params)
    end
    menu_item
  end

  def self.call(verbose =  true)
    new.call(verbose)
  end

  def call(verbose = true)
    menu_list_file = Rails.root.join('config', 'smartkhata', 'menu.yml')
    menu_list = YAML::load(ERB.new(File.read(menu_list_file)).result(binding))

    tenants = Tenant.all

    tenants.each do |t|
      begin
        Apartment::Tenant.switch!(t.name)
        # check for any duplicate menu item codes in menu.yml file, and return with false
        if menu_list_has_duplicate_codes(menu_list)
          puts "Error! Menu.yml has duplicate codes."
          puts "Can't proceed with the operation."
          return false
        end
        # keep track of the menus created or updated
        # and delete the rest
        new_menu_lists = []
        menu_list['menus'].each do |menu|
          params = {name: menu['name'], code: menu['code'], path: menu['path'], hide_on_main_navigation: menu['hide_on_main_navigation'], request_type: menu['request_type']}
          menu_item = find_or_create_by_code(params)
          new_menu_lists << menu_item.id
          menu['menu_item_id'] = menu_item.id
          sub_menu_list = menu['sub_menus'] || []
          sub_menu_list.each do |sub_menu|
            params = {name: sub_menu['name'], code: sub_menu['code'], path: sub_menu['path'], hide_on_main_navigation: sub_menu['hide_on_main_navigation'], request_type: menu['request_type']}
            puts sub_menu['name'] if verbose

            sub_menu_item = find_or_create_by_code(params)
            new_menu_lists << sub_menu_item.id
            sub_menu_item.update_attribute :parent, menu_item

            sub_menu['menu_item_id'] = sub_menu_item.id
            inner_menu_list = sub_menu['menu_items'] || []
            inner_menu_list.each do |menu_item|
              params = {name: menu_item['name'], code: menu_item['code'], path: menu_item['path'], hide_on_main_navigation: menu_item['hide_on_main_navigation'], request_type: menu['request_type']}

              _menu_item = find_or_create_by_code(params)
              new_menu_lists << _menu_item.id
              _menu_item.update_attribute :parent, sub_menu_item

              # TODO Subas unsure about this code
              menu_item['menu_item_id'] = _menu_item.id
            end
          end
        end
        MenuItem.where.not(id: new_menu_lists).destroy_all
      rescue => error
        puts error.message  if verbose
        puts "Tenant #{t.name} exists"  if verbose
      end
    end


    # keeping the menu.yml file intact
    Apartment::Tenant.switch!('public')


    case Rails.env
      when "test"
        #   nothing yet
      else
        menu_list = YAML::load_file(menu_list_file)
        File.open(menu_list_file, 'w') do |h|
          h.puts "#"
          h.puts "# available action/menus"
          h.puts "# default request_type is get"
          h.puts "#"
          h.write menu_list.to_yaml
        end
    end

    true
  end


  def delete_all
    tenants = Tenant.all
    tenants.each do |t|
      Apartment::Tenant.switch!(t.name)
      MenuPermission.delete_all
      MenuItem.delete_all
    end
    Apartment::Tenant.switch!('public')
    return true
  end

  def all_codes_in_menu_list(menu_list)
    codes = []
    menu_list['menus'].each do |menu|
      codes << menu['code']
      sub_menu_list = menu['sub_menus'] || []
      sub_menu_list.each do |sub_menu|
        codes << sub_menu['code']
        inner_menu_list = sub_menu['menu_items'] || []
        inner_menu_list.each do |menu_item|
          codes << menu_item['code']
        end
      end
    end
    codes
  end

  def menu_list_has_duplicate_codes(menu_list)
    arr = all_codes_in_menu_list(menu_list)
    arr.detect{ |e| arr.count(e) > 1 }
  end
end

