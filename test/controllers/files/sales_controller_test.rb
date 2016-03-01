require 'test_helper'

class Files::SalesControllerTest < ActionController::TestCase
  # test "the truth" do
  #   assert true
  # end
  test "should get new"  do
    get :new
    assert_response :success
    assert_select ".section-title", "Upload Sales CM file"
  end
  # test "should get import"  do
  #   get :import
  #   assert_response :success
  #   assert_select ".section-title", "Upload Sales CM file"
  # end
end
