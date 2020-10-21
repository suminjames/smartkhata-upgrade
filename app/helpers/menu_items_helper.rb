module MenuItemsHelper
  def get_grouped_menu_items
    all_menu_items = Menu_Item.all.to_a
    top_level_menu_items = MenuItem.first_level_menu_items

    menu_items = {}
    menu_items[:menus] = []

    top_level_menu_items.each do |menu_item|
      if menu_item.path.present?
        menu_items[:menus] |= menu_item
      else
        submenu = {}
        menu_item.children.each do |sub_menu|
        end
      end
    end
  end

  def restricted_for_user path
    if current_user.admin?
      false
    else
      paths_only_for_admins.include?(path)
    end
  end

  def paths_only_for_admins
    [
      restricted_ledgers_path
    ]
  end
end
