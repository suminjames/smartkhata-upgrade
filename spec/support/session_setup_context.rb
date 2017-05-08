shared_context 'session_setup' do
  before do
    UserSession.user = create(:user)
    UserSession.selected_fy_code = 7374
    UserSession.selected_branch_id =  1
  end
end