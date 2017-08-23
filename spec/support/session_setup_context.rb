shared_context 'session_setup' do
  before do
    @branch = create(:branch)
    Ledger.find_or_create_by(name: "Cash")
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
    @branch = create(:branch)
    Ledger.find_or_create_by(name: "Cash")
    # making usr
    allow(@branch).to receive(:id).and_return(1)
    @user = create(:user, branch_id: 1)
    UserSession.user = @user
    UserSession.selected_fy_code = 7374
    UserSession.selected_branch_id = @branch.id
  end
  after(:each) do
    Warden.test_reset!
  end
end

shared_examples "user not signed in" do
  it "redirects to login page with message" do
    expect(page).to have_content("You need to sign in or sign up before continuing.")
    expect(page).to have_content("Login")
    expect(page).to have_content("Password")
    expect(page).to have_content("Remember me")
  end
end

