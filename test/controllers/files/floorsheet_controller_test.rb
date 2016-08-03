
require 'test_helper'

class Files::FloorsheetsControllerTest < ActionController::TestCase
  def setup
    @user = users(:user)
    # setup relevant fycode
    set_fy_code 7273
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
    # fix tenants issue
    @request.host = 'trishakti.lvh.me'
    # error messages
    @amounts_dont_matchup_msg = 'the amount dont match up'
  end

  # index
  test "should get index" do
    @assert_block_via_login_and_get.call(:index)
  end

  # new
  test "should get new" do
    @assert_block_via_login_and_get.call(:new)
  end

  # import
  test "should be able to import a file once" do
    @assert_block_via_login_and_post.call('valid', false)
    # duplicate import
    @post_action.call('valid')
    assert_contains 'the file is already uploaded', flash[:error]
  end

  test "should be able to import several files if distinct ones" do
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

  test "should not import invalid file: last data row missing" do
    @assert_block_via_login_and_post.call('invalid', @amounts_dont_matchup_msg, 3)
  end

  test "should not import invalid file: total rows missing" do
    @assert_block_via_login_and_post.call('invalid', @amounts_dont_matchup_msg, 4)
  end

=begin
  # Needs to be fixed in Controller: Generates errors
  test "should not import invalid file: all data rows missing" do
    @assert_block_via_login_and_post.call('invalid', 'please upload a valid file. are you uploading the processed floorsheet file?', 2)
  end
  test "should not import invalid file: blank" do
    @assert_block_via_login_and_post.call('invalid', 'please upload a valid file', 5)
  end
=end
end
