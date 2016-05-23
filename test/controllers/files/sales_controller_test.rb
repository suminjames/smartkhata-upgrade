require 'test_helper'

class Files::SalesControllerTest < ActionController::TestCase
  def setup
    # No idea why two settlements appear out of nowhere in the very beginning, causing date errors;
    # Found out: Fixtures, of course!
    # SalesSettlement.all.each.map(&:destroy!)
    @user = users(:user)
    @post_floorsheet_action = Proc.new{ | different_floorsheet |
      sales_controller = @controller
      @controller = Files::FloorsheetsController.new
      inner_file_path = different_floorsheet ? 'May12/BrokerwiseFloorSheetReport 12 May.xls' : 'May10/BrokerwiseFloorSheetReport 10 May.xls'
      file = fixture_file_upload("files/#{inner_file_path}", 'text/xls')
      post :import, file: file
      get :index
      assert_not assigns(:file_list).empty?
      @controller = sales_controller
      # debugger
    }
    @post_action = Proc.new { | test_type, sample_file |
      file_type = 'text/csv'
      inner_file_path = case test_type
        when 'valid' || 'invalid'
          'May10/CM0518052016141937.csv'
        when 'valid again'
          'May12/CM0518052016142014.csv'
        when 'invalid'
          if sample_file
            file_name_suffix = case sample_file
              when 1 then 'missing_settlement_id'
              when 2 then 'multiple_settlements'
              when 3 then 'missing_trade_date'
              when 4 then 'missing_contract_number'
              when 5 then 'missing_header_row'
              when 6 then 'missing_data_rows'
              when 7 then 'blank'
            end
            "invalid_files/May10/CM0518052016141937__#{file_name_suffix}.csv"
          else
            file_type = 'text/xls'
            'MAy10/BrokerwiseFloorSheetReport 10 May.xls'
          end
      end
      file = fixture_file_upload("files/#{inner_file_path}", file_type)
      post :import, file: file
      # debugger
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
      # sales_post_type = case
      # when test_type == 'valid again'
      #   test_type
      # when flash_msg
      #   'invalid'
      # else
      #   'valid'
      # end

      if test_type == "invalid" && flash_msg == @missing_floorsheet_msg && !file_num
        post_action_type = 'valid'
      else
        post_action_type = test_type
      end
      @post_action.call(post_action_type, file_num)
      if test_type == 'valid'
        assert_redirected_to sales_settlement_path(assigns(:sales_settlement_id))
      # elsif test_type == 'invalid' && file_num
      #   assert_redirected_to import_files_sales_path
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
    # Error messages
    @missing_contract_number_msg = 'the file you have uploaded has missing contract number'
    @missing_floorsheet_msg = 'please upload corresponding floorsheet first'
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
  test "bar" do
  # test "authenticated users should be able to import a file once" do
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
    @assert_block_via_login_and_post.call('invalid', @missing_floorsheet_msg, nil, true)
  end
  test "should not import sales cm without the corresponding floorsheet" do
    @assert_block_via_login_and_post.call('invalid', @missing_floorsheet_msg, nil)
  end


  # explicit invalid files
  test "should not import invalid sales cm: missing settlement id" do
    # The missing floorsheet error message because settlement id column is not explicitly checked
    @assert_block_via_login_and_post.call('invalid', @missing_floorsheet_msg, 1)
  end
  test "should not import invalid sales cm: multiple settlements" do
    @assert_block_via_login_and_post.call('invalid', 'The file you have uploaded has multiple settlement ids', 2) # error
  end
  test "should not import invalid sales cm: trade date missing" do
    @assert_block_via_login_and_post.call('invalid', 'please upload a correct file. trade date is missing', 3)
  end
  test "should not import invalid sales cm: missing contract number" do
    @assert_block_via_login_and_post.call('invalid', @missing_contract_number_msg, 4)
  end
  test "should not import invalid sales cm: missing header rows" do
    # Contract number column check hits first
    @assert_block_via_login_and_post.call('invalid', @missing_contract_number_msg, 5)
  end
  test "should not import invalid sales cm: missing data rows" do
    # Contract number column check hits first
    @assert_block_via_login_and_post.call('invalid', @missing_contract_number_msg, 6)
  end
  test "should not import invalid sales cm: blank" do
    # Contract number column check hits first
    @assert_block_via_login_and_post.call('invalid', @missing_contract_number_msg, 7)
  end

  test "unauthenticated users should not be able to import" do
    @post_action.call('valid')
    assert_redirected_to new_user_session_path
  end

end
