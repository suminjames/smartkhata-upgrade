
require 'test_helper'

class Files::FloorsheetsControllerTest < ActionController::TestCase
  def setup
    @user = users(:user)
    @post_action = Proc.new { | test_type, sample_file |
      file_type = 'text/xls'
      file_path = case test_type
        when 'valid'
          'files/May10/BrokerwiseFloorSheetReport 10 May.xls'
        when 'valid again'
          'files/May12/BrokerwiseFloorSheetReport 12 May.xls'
        when 'invalid'
          if sample_file
            file_name_suffix = case sample_file
              when 1 then 'missing_header_row'
              when 2 then 'missing_data_rows'
              when 3 then 'missing_last_data_row'
              when 4 then 'missing_total_rows'
              when 5 then 'blank'
            end
            "files/invalid_files/May10/BrokerwiseFloorSheetReport 10 May__#{file_name_suffix}.xls"
          else
            file_type = 'text/csv'
            'files/May10/CM0518052016141937.csv'
          end
      end
      file = fixture_file_upload(file_path, file_type)
      post :import, file: file
    }
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
    # error messages
    @amounts_dont_matchup_msg = 'the amount dont match up'
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
    # another import
    @post_action.call('valid again')
    get :index
    assert_equal assigns(:file_list).count, 2
  end

  # explicit invalid files
  test "should not import invalid file: csv" do
    @assert_block_via_login_and_post.call('invalid', 'please upload a valid file')
  end

  test "should not import invalid file: header row missing" do
    @assert_block_via_login_and_post.call('invalid', @amounts_dont_matchup_msg, 1)
  end

  # test "bar" do
  test "should not import invalid file: last data row missing" do
    @assert_block_via_login_and_post.call('invalid', 'please upload a valid file. are you uploading the processed floorsheet file?', 2)
  end

  test "should not import invalid file: all data rows missing" do
    @assert_block_via_login_and_post.call('invalid', @amounts_dont_matchup_msg, 3)
  end

  test "should not import invalid file: total rows missing" do
    @assert_block_via_login_and_post.call('invalid', @amounts_dont_matchup_msg, 4)
  end

  test "should not import invalid file: blank" do
    @assert_block_via_login_and_post.call('invalid', 'please upload a valid file', 5)
  end

  test "unauthenticated users should not be able to import" do
    @post_action.call('valid')
    assert_redirected_to new_user_session_path
  end

  # MORE TESTS!!!
  # Check controller:66- case '@date.nil'

end
