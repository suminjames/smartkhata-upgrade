require 'test_helper'

class Files::SalesControllerTest < ActionController::TestCase
  def setup
    @user = users(:user)
    @post_floorsheet_action = Proc.new{ | different_floorsheet |
      sales_controller = @controller
      @controller = Files::FloorsheetsController.new
      filename = different_floorsheet ? 'May4/BrokerwiseFloorSheetReport 4 May.xls' : 'May10/BrokerwiseFloorSheetReport 10 May.xls'
      file = fixture_file_upload("files/#{filename}", 'text/xls')
      post :import, file: file
      @controller = sales_controller
    }
    @test_proc = Proc.new { |param| }
    @post_action = Proc.new { | test_type, sample_file |
      file_type = 'text/csv'
      file_path = case test_type
        when 'valid'
          'files/May10/CM0518052016141937.csv'
        when 'valid again'
          'files/May4/CM0518052016141832.csv'
        when 'invalid'
          if sample_file
            # file_name_suffix = case sample_file
            #   when 1 then 'header_row_missing.xls'
            #   when 2 then 'last_data_row_and_formulae_missing.xls'
            #   when 3 then 'data_rows_and_formulae_missing.xls'
            #   when 4 then 'blank.xls'
            # end
            # "files/invalid_files/Floorsheet_April_04__#{file_name_suffix}"
          else
            file_type = 'text/xls'
            'files/MAy10/BrokerwiseFloorSheetReport 10 May.xls'
          end
      end
      file = fixture_file_upload(file_path, file_type)
      post :import, file: file
    }
    @block_assert_via_login_and_get = lambda { | action |
      sign_in @user
      get action
      assert_response :success
      assert_template "files/sales/#{action}"
      assert_not_nil assigns(:file_list) if action == :new
    }
    @assert_block_via_login_and_post = Proc.new { | test_type, flash_msg, file_num, avoid_floorsheet |
      sign_in @user
      unless avoid_floorsheet
        different_floorsheet = (test_type == "invalid" && !file_num && !avoid_floorsheet) || (test_type == "valid again")
        @post_floorsheet_action.call(different_floorsheet)
      end
      sales_post_type = case
      when test_type == 'valid again'
        test_type
      when flash_msg == 'please upload a valid file'
        'invalid'
      else
        'valid'
      end
      @post_action.call(sales_post_type, file_num)
      if test_type == 'valid'
        assert_redirected_to sales_settlement_path(assigns(:sales_settlement_id))
      else
        assert_response :success
        assert_template 'files/sales/import'
      end
      if flash_msg
        assert_contains flash_msg, flash[:error]
      elsif flash_msg == false
        assert flash.empty?
      end
      get :index
      case test_type
      when 'valid'
        assert_not assigns(:file_list).empty?
      when 'valid again'
        assert_equal assigns(:file_list).count, 2
      else
        assert assigns(:file_list).empty?
      end
    }
  end

  # index
  test "authenticated user should get index" do
    @block_assert_via_login_and_get.call(:index)
  end
  test "unauthenticated users should get not get index" do
    get :index
    assert_redirected_to new_user_session_path
  end

  # new
  test "authenticated users should get new" do
    @block_assert_via_login_and_get.call(:new)
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
    @post_action.call('valid again', false)
  end

  # invalid imports
  test "should not import invalid file" do
    @assert_block_via_login_and_post.call('invalid', 'please upload a valid file')
  end
  test "should not import sales cm without a floorsheet" do
    @assert_block_via_login_and_post.call('invalid', 'please upload corresponding floorsheet first', nil, true)
  end
  test "should not import sales cm without the corresponding floorsheet" do
    @assert_block_via_login_and_post.call('invalid', 'please upload corresponding floorsheet first', nil)
  end
  test "unauthenticated users should not be able to import" do
    @post_action.call('valid')
    assert_redirected_to new_user_session_path
  end
end
