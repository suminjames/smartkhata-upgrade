shared_context 'session_setup' do
  before do
    @user = create(:user)
    @branch = @user.branch
    UserSession.user = @user
    UserSession.selected_fy_code = 7374
    UserSession.selected_branch_id = @branch.id
  end
end