
require 'test_helper'

class GeneralSettingsControllerTest < ActionController::TestCase
  def setup
    sign_in users(:user)
  end

  test "should set fy code" do
    # UserSession gets carried on in bulk tests
    [ UserSession.selected_fy_code,
      session[:user_selected_fy_code],
      UserSession.selected_branch_id,
      session[:user_selected_branch_id]].each {|s| s = nil}

    get :set_fy, {fy_code: 7273, branch_id: 10}
    assert_redirected_to root_path #just a reload

    assert({UserSession.selected_fy_code => 7273,
            session[:user_selected_fy_code] => 7273,
            UserSession.selected_branch_id => 10,
            session[:user_selected_branch_id] => 10}.all? {|k,v| k == v })
  end
end
