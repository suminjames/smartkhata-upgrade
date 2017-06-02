shared_context 'session_setup' do
  let(:user){create(:user)}
  let(:branch) { user.branch }
  before do
    UserSession.user = user
    UserSession.selected_fy_code = 7374
    UserSession.selected_branch_id = branch.id
  end
end