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
    @assert_block_via_login_and_post = Proc.new { | test_type, flash_msg, file_num |
      sign_in @user
      @post_action.call(test_type, file_num)
      assert_response :success
      if flash_msg
        assert_contains flash_msg, flash[:error]
      elsif flash_msg == false
        assert flash.empty?
      end
      assert_template 'files/floorsheets/import'
      get :index
      if test_type == 'valid'
        assert_not assigns(:file_list).empty?
      else
        assert assigns(:file_list).empty?
      end
    }
    @post_action = Proc.new { | test_type, sample_file |
      file_type = 'text/xls'
      file_path = case test_type
        when 'valid'
          'files/Floorsheet_apr_04.xls'
        when 'valid again'
          'files/Floorsheet_apr_10.xls'
        else
          if sample_file
            file_name_suffix = case sample_file
              when 1 then 'header_row_missing.xls'
              when 2 then 'last_data_row_and_formulae_missing.xls'
              when 3 then 'data_rows_and_formulae_missing.xls'
              when 4 then 'blank.xls'
            end
            "files/invalid_files/Floorsheet_April_04__#{file_name_suffix}"
          else
            file_type = 'text/csv'
            'files/CM054april_test.csv'
          end
      end
      file = fixture_file_upload(file_path, file_type)
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
    @assert_block_via_login_and_post.call('valid', false)
    # duplicate import
    @post_action.call('valid')
    assert_contains 'the file is already uploaded', flash[:error]
  end

  test "authenticated users should be able to import several files if distinct ones" do
    @assert_block_via_login_and_post.call('valid', false)
    # duplicate import
    @post_action.call('valid again')
    get :index
    assert_equal assigns(:file_list).count, 2
  end

  test "should not import invalid file: csv" do
    @assert_block_via_login_and_post.call('invalid', 'please upload a valid file')
  end

  test "should not import invalid file: header row missing" do
    @assert_block_via_login_and_post.call('invalid', 'please upload a valid file', 1)
  end

  # test "should not import invalid file: last data row missing" do
  test "bar" do
    @assert_block_via_login_and_post.call('invalid', 'the amount dont match up', 2)
  end

  test "should not import invalid file: data rows missing" do
    @assert_block_via_login_and_post.call('invalid', 'please verify and upload a valid file', 3)
  end

  test "should not import invalid file: blank" do
    @assert_block_via_login_and_post.call('invalid', 'please upload a valid file', 4)
  end

  test "unauthenticated users should not be able to import" do
    @post_action.call('valid')
    assert_redirected_to new_user_session_path
  end

  # MORE TESTS!!!
  # Check controller:66- case '@date.nil'

end
