require 'test_helper'

class ParticularsControllerTest < ActionController::TestCase
  setup do
    @particular = particulars(:one)
  end

# A particular will not have get index.
# They will be seen as children of a ledger.
  # test "should get index" do
  #   get :index
  #   assert_response :success
  #   assert_not_nil assigns(:particulars)
  # end

# Creation of particular takes place as a subset of voucher instead.
  # test "should get new" do
  #   get :new
  #   assert_response :success
  # end

# Creation of particular takes place as a subset of voucher instead.
  # test "should create particular" do
  #   assert_difference('Particular.count') do
  #     post :create, particular: {  }
  #   end
  #
  #   assert_redirected_to particular_path(assigns(:particular))
  # end

# A particular will not have a separate 'show'.
# It is instead shown via ledgers only.
  # test "should show particular" do
  #   get :show, id: @particular
  #   assert_response :success
  # end

# A particular should not be edited.
  # test "should get edit" do
  #   get :edit, id: @particular
  #   assert_response :success
  # end

# A particular should not be updated.
  # test "should update particular" do
  #   patch :update, id: @particular, particular: {  }
  #   assert_redirected_to particular_path(assigns(:particular))
  # end

# Deletion of particular is forbidden.
  # test "should destroy particular" do
  #   assert_difference('Particular.count', -1) do
  #     delete :destroy, id: @particular
  #   end
  #
  #   assert_redirected_to particulars_path
  # end
end
