module MenuPermissionModule
  #
  # return the permitted menu list after filtering the blocked menus
  #
  def permitted_menu_list(menu_list, user_id)
    # remove menu items from the list if it contains the blocked path
    blocked_path_list = get_blocked_path_list
    menu_list.each do |menu|
      next if menu['sub_menus'].blank?

      sub_menus = menu['sub_menus'] || []

      sub_menus.each do |sub_menu|
        sub_menu['menu_items'].delete_if { |x| is_blocked_path(x['path'], blocked_path_list) }
      end

      # remove the sub menus that dont have any items present and are without links
      menu['sub_menus'].delete_if { |x| (x['path'].blank? && x['menu_items'].empty?) || (x['path'].present? && is_blocked_path(x['path'], blocked_path_list)) }
    end

    # delete all the menus that dont have submenus and are without links
    menu_list.delete_if do |x|
      (x['path'].blank? && x['sub_menus'].empty?) || (x['path'].present? && is_blocked_path(x['path'], blocked_path_list))
    end
    menu_list
  end

  #
  # Get Blocked path list for the current user
  # user id should be passed because this method is also being called from user model
  # and model dont have access to current_user helper
  #
  def get_blocked_path_list(user_access_role_id = current_user.user_access_role_id)
    MenuItem.black_listed_paths_for_user(user_access_role_id)
  end

  #
  # Check if the path is blocked or not
  #
  def is_blocked_path(path, blocked_path_list = get_blocked_path_list)
    !(current_user.admin? || current_user.sys_admin?) && blocked_path_list.include?(agnostic_path(path))
  end

  def user_has_access_to?(link)
    admin_and_above? || current_user.client? || !current_user.blocked_path_list.include?(agnostic_path(link))
  end

  def agnostic_path link
    link_params = link.split('/')
    "/:fy_code/:branch_id/#{link_params[3..-1].join('/')}" rescue link
  end

end
