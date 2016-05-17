require 'test_helper'

class Files::FloorsheetsControllerTest < ActionController::TestCase
  def setup
    @user = users(:user)
    @assert_block_via_login_and_get = lambda { | action |
      sign_in @user
      get action
      assert_response :success
      assert_template "files/floorsheets/#{action}"
      assert_not_nil assigns(:file_list)
    }
    @post_action = lambda { | test_type |
      if test_type == 'valid'
        file = fixture_file_upload('files/Floorsheet_apr_04.xls', 'text/xls')
      else
        file = fixture_file_upload('files/CM054april_test.csv', 'text/csv')
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
    # puts "--------------------------------flash.inspect-------------------------------------"
    # puts flash.inspect
    # puts "----------------------------------------------------------------------------------"
    assert_response :success
    assert_template 'files/floorsheets/import'
    assert flash.empty?

    # VERIFY THAT THE FILE WAS IMPORTED
    #

    # dulpicate import
    @post_action.call('valid')
    assert_contains 'the file is already uploaded', flash[:error]
  end
  test "should not import invalid file" do
    sign_in @user
    @post_action.call('invalid')
    assert_response :success
    assert_contains 'please upload a valid file', flash[:error]
    assert_template 'files/floorsheets/import'

    # VERIFY THAT THE FILE WAS NOT IMPORTED
    #
  end
  test "unauthenticated users should not be able to import" do
    @post_action.call('valid')
    assert_redirected_to new_user_session_path
  end

end
