require 'test_helper'

class GeneralSettingsControllerTest < ActionController::TestCase
  test "should get set_fy" do
    get :set_fy
    assert_response :success
  end

  test "should get set_branch" do
    get :set_branch
    assert_response :success
  end

end
