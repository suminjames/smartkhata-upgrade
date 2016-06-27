require 'test_helper'

class Files::Dpa5ControllerTest < ActionController::TestCase
  def setup
    sign_in users(:user)
    @assert_block_via_get = lambda { | action |
      get action
      assert_response :success
      assert_template "files/dpa5/#{action}"
      assert_not_nil assigns(:file_list)
    }
    @post_action = lambda { | file_path |
      fixture_file_path = "files/#{file_path}"
      post :import, file: fixture_file_upload(fixture_file_path)
    }
  end

  test "should get new" do
    @assert_block_via_get.call(:new)
  end

  test "should get index" do
    @assert_block_via_get.call(:index)
  end

  test "should import valid file" do
    @post_action.call('undated/08DPA5UINCREMENTALTEST')
    assert_response :success
    # No flash message implemented here!
    # assert_equal "Successfully uploaded and processed the file.", flash[:notice]
    assert_template 'files/dpa5/import'
    get :index
    assert_not assigns(:file_list).empty?
  end

  test "should not import file with invalid name" do
    @post_action.call('May10/BrokerwiseFloorSheetReport 10 May.xls')
    # Why no redirect here?
    assert_response :success
    assert_equal "Please Upload a valid file", flash[:error]
    get :index
    assert assigns(:file_list).empty?
  end

  # No explicit validity checking in dpa5 upload service
end