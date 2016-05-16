require 'test_helper'

class Files::SalesControllerTest < ActionController::TestCase
  def setup
    @user = users(:user)
    @assert_block_via_login_and_get = lambda { | action |
      sign_in @user
      get action
      assert_response :success
      assert_template "files/sales/#{action}"
      assert_not_nil assigns(:file_list) if action == :new
    }
    @post_action = Proc.new { | test_type, avoid_floorsheet |
      unless avoid_floorsheet
        # First upload the corresponding floorsheet
        sales_controller = @controller
        @controller = Files::FloorsheetsController.new
        file = fixture_file_upload('files/Floorsheet_apr_04.xls', 'text/xls')
        post :import, file: file
        @controller = sales_controller
      end

      if test_type == 'valid'
        file = fixture_file_upload('files/CM054april_test.csv', 'text/csv')
      else
        file = fixture_file_upload('files/Floorsheet_apr_04.xls', 'text/xls')
      end
        post :import, file: file
    }
  end

  # index
  test "authenticated user should get index" do
    @assert_block_via_login_and_get.call(:index)
  end
  test "unauthenticated users should get not get index" do
    get :index
    assert_redirected_to new_user_session_path
  end

  # new
  test "authenticated users should get new" do
    @assert_block_via_login_and_get.call(:new)
  end
  test "unauthenticated users should not get new" do
    get :new
    assert_redirected_to new_user_session_path
  end


  # import
  test "authenticated users should be able to import a file once" do
    sign_in @user
    @post_action.call('valid')
    assert flash.empty?
    assert_redirected_to sales_settlement_path(assigns(:sales_settlement_id))

    # VERIFY THAT THE FILE WAS IMPORTED
    #

    # duplicate import
    @post_action.call('valid')
    assert_not flash.empty?
    assert_response :success
  end
  test "should not import invalid file" do
    sign_in @user
    @post_action.call('invalid')
    assert_response :success
    assert_not flash.empty?
    assert_template 'files/sales/import'

    # VERIFY THAT THE FILE WAS NOT IMPORTED
    #
  end
  test "should not import sales cm without the corresponding floorsheet" do
    sign_in @user
    @post_action.call('valid', true)
    assert_response :success
    assert_not flash.empty?

    # VERIFY THAT THE FILE WAS NOT IMPORTED
    #
  end
  test "unauthenticated users should not be able to import" do
    @post_action.call('valid')
    assert_redirected_to new_user_session_path
  end
end
