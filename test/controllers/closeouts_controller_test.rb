=begin
require 'test_helper'

class CloseoutsControllerTest < ActionController::TestCase
  setup do
    @closeout = closeouts(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:closeouts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create closeout" do
    assert_difference('Closeout.count') do
      post :create, closeout: {  }
    end

    assert_redirected_to closeout_path(assigns(:closeout))
  end

  test "should show closeout" do
    get :show, id: @closeout
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @closeout
    assert_response :success
  end

  test "should update closeout" do
    patch :update, id: @closeout, closeout: {  }
    assert_redirected_to closeout_path(assigns(:closeout))
  end

  test "should destroy closeout" do
    assert_difference('Closeout.count', -1) do
      delete :destroy, id: @closeout
    end

    assert_redirected_to closeouts_path
  end
end
=end