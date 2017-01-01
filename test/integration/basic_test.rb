require "test_helper"

class BasicTest < ActionDispatch::IntegrationTest
  include Warden::Test::Helpers
  Warden.test_mode!

  setup do
    @user = create(:user)
    login_as(@user, :scope => :user)
  end
  teardown do
    Warden.test_reset!
  end

  test "already login" do
    visit root_path
    write_to_html(page.body)
    assert current_path , 'dashboard/index'
  end
end