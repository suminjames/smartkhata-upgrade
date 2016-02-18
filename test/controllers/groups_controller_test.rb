require 'test_helper'

class GroupsControllerTest < ActionController::TestCase
  setup do
    @group = groups(:one)
  end

# TODO
  # test "should get index" do
  #   get :index
  #   assert_response :success
  #   assert_not_nil assigns(:groups)
  # end

# TODO
  # test "should get new" do
  #   get :new
  #   assert_response :success
  # end

# TODO
  # test "should create group" do
  #   assert_difference('Group.count') do
  #     post :create, group: {  }
  #   end
  #
  #   assert_redirected_to group_path(assigns(:group))
  # end

# TODO
  # test "should show group" do
  #   get :show, id: @group
  #   assert_response :success
  # end

# TODO
  # test "should get edit" do
  #   get :edit, id: @group
  #   assert_response :success
  # end

# TODO
  # test "should update group" do
  #   patch :update, id: @group, group: {  }
  #   assert_redirected_to group_path(assigns(:group))
  # end

# Currently group destroy will not be implemented.
# However, soft-deletion might be implemented, if desired by client in the future.
  # test "should destroy group" do
  #   assert_difference('Group.count', -1) do
  #     delete :destroy, id: @group
  #   end
  #
  #   assert_redirected_to groups_path
  # end
end
