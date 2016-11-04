module BranchPermissionModule

  #
  # Get Blocked path list for the current user
  # user id should be passed because this method is also being called from user model
  # and model dont have access to current_user helper
  #
  def permitted_branches(user = current_user)
    if !user.client?
      Branch.permitted_branches_for_user(user)
    else
      [user.branch]
    end
  end

end