
require 'test_helper'

class Files::FloorsheetsControllerTest < ActionController::TestCase
  # test "the truth" do
  #   assert true
  # end
  test "should get new"  do
    get :new
    assert_response :success
    assert_select ".section-title", "Upload FloorSheet file"
  end
end
