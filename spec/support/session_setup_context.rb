shared_context 'session_setup' do
  before do
    @branch = create(:branch)
    # making usr
    allow(@branch).to receive(:id).and_return(1)
    @user = create(:user, branch_id: 1)
    UserSession.user = @user
    UserSession.selected_fy_code = 7374
    UserSession.selected_branch_id = @branch.id
  end
end

shared_context 'feature_session_setup' do
  before do
    @user = create(:user)
    @branch = @user.branch
    UserSession.user = @user
    UserSession.selected_fy_code = 7374
    UserSession.selected_branch_id = @branch.id
  end

  after(:each) do
    Warden.test_reset!
  end
end

