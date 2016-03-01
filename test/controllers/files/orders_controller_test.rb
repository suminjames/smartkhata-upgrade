require 'test_helper'

class Files::OrdersControllerTest < ActionController::TestCase
  # test "the truth" do
  #   assert true
  # end

  test "should get new"  do
    get :new
    assert_response :success
    assert_select ".section-title", "Upload Order file"
  end

end
