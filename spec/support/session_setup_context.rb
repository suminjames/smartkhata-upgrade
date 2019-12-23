shared_context 'session_setup' do
  before do
    @branch = create(:branch)
    @fy_code = 7374
    Ledger.find_or_create_by(name: "Cash")
    # making usr
    allow(@branch).to receive(:id).and_return(1)
    @user = create(:user, branch_id: 1)
    UserSession.user = @user
    UserSession.selected_fy_code = @fy_code
    UserSession.selected_branch_id = @branch.id
  end
end

shared_context 'feature_session_setup' do
  before do
    @branch = create(:branch)
    @fy_code = 7374
    allow(@branch).to receive(:id).and_return(1)
    # making usr
    @user = create(:user, branch_id: 1)
    Ledger.create(name: "Cash")
    UserSession.user = @user
    UserSession.selected_fy_code = @fy_code
    UserSession.selected_branch_id = @branch.id

    # we dont want the application controller to set user session
    # as we are overriding the UserSession variable
    # allow_any_instance_of(ApplicationController).to receive(:set_user_session).and_return(true)
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

