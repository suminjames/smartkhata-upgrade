module MenuPermissionModule

  #
  # return the permitted menu list after filtering the blocked menus
  #
  def permitted_menu_list(menu_list, user_id)
    # remove menu items from the list if it contains the blocked path
    menu_list.each do |menu|
      if menu['sub_menus'].present?
        sub_menus =menu['sub_menus'] || []

        sub_menus.each do |sub_menu|
          sub_menu['menu_items'].delete_if { |x| is_blocked_path(blocked_path_list, x['path']) }
        end

        # remove the sub menus that dont have any items present and are without links
        menu['sub_menus'].delete_if { |x| (!x['path'].present? && x['menu_items'].size < 1) || (x['path'].present? && is_blocked_path(blocked_path_list, x['path'])) }
      end
    end

    # delete all the menus that dont have submenus and are without links
    menu_list.delete_if {
        |x| (!x['path'].present? && x['sub_menus'].size < 1) || (x['path'].present? && is_blocked_path(blocked_path_list, x['path'])) }
    menu_list
  end

  #
  # Get Blocked path list for the current user
  #
  def get_blocked_path_list
    MenuItem.all.pluck(:path).to_a.compact
  end

  #
  # Check if the path is blocked or not
  #
  def is_blocked_path(blocked_path_list, path)
    !( current_user.admin? || current_user.sys_admin?) && ( blocked_path_list.include? path)
  end

  #
  # get blocked path_list from session
  #
  def blocked_path_list
    get_blocked_path_list
    # session['blocked_path_list']
  end
end
