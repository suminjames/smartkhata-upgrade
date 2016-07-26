require 'test_helper'

class Files::SalesControllerTest < ActionController::TestCase
  def setup
    # SalesSettlement.all.each.map(&:destroy!) # fixtures
    sign_in users(:user)
    # setup relevant fycode
    UserSession.selected_fy_code = session[:user_selected_fy_code] = 7273
    @post_floorsheet_action = Proc.new{ | different_floorsheet |
      sales_controller = @controller
      @controller = Files::FloorsheetsController.new
      inner_file_path = different_floorsheet ? 'May12/BrokerwiseFloorSheetReport 12 May.xls' : 'May10/BrokerwiseFloorSheetReport 10 May.xls'
      file = fixture_file_upload("files/#{inner_file_path}", 'text/xls')
      post :import, file: file
      get :index
      assert assigns(:file_list).present?
      @controller = sales_controller
    }
    @post_action = Proc.new { | test_type, sample_file |
      file_type = 'text/csv'
      inner_file_path = case test_type
        when 'valid'
          'May10/CM0518052016141937.csv'
        when 'valid again'
          'May12/CM0518052016142014.csv'
        when 'invalid'
          if sample_file
            file_name_suffix = case sample_file
              when 1 then 'missing_settlement_id'
              when 2 then 'multiple_settlement_ids'
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
    }
    @block_assert_via_get = lambda { | action |
      get action
      assert_response :success
      assert_template "files/sales/#{action}"
      assert_not_nil assigns(:settlements)
    }
    @assert_block_via_post = Proc.new { | test_type, flash_msg, file_num, avoid_floorsheet |
      unless avoid_floorsheet
        different_floorsheet = (test_type == "invalid" && !file_num && !avoid_floorsheet) || (test_type == "valid again")
        @post_floorsheet_action.call(different_floorsheet)
      end
      if test_type == "invalid" && flash_msg == @missing_floorsheet_msg && !file_num
        post_action_type = 'valid'
      else
        post_action_type = test_type
      end
      @post_action.call(post_action_type, file_num)
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
      file_count = case test_type
      when 'valid' then 1
      when 'valid again' then 2
      else 0
      end
      assert_equal @sales_settlements_in_fixtures + file_count, SalesSettlement.count
      # assert_equal @sales_settlements_in_fixtures + file_count, assigns(:file_list).count
    }
    # fix tenants issue
    @request.host = 'trishakti.lvh.me'
    @sales_settlements_in_fixtures = 2
    # Error messages
    @missing_contract_number_msg = 'the file you have uploaded has missing contract number'
    @missing_floorsheet_msg = 'please upload corresponding floorsheet first'
  end

  # index
  test "should get index" do
    @block_assert_via_get.call(:index)
  end

  # new
  test "should get new" do
    @block_assert_via_get.call(:new)
  end

  # import
  test "should be able to import a file once" do
    # NEED TO CHANGE THE FISCAL YEAR (Floorsheet)
    @assert_block_via_post.call('valid', false)
    # duplicate import
    @post_action.call('valid')
    assert_contains 'the file is already uploaded', flash[:error]
  end

  test "should be able to import several files if distinct ones" do
    # NEED TO CHANGE THE FISCAL YEAR (Floorsheet)
    @assert_block_via_post.call('valid', false)
    # another import
    @post_action.call('valid again', false)
  end

  # invalid imports
  test "should not import invalid file" do
    @assert_block_via_post.call('invalid', 'please upload a valid file')
  end
  test "should not import sales cm without a floorsheet" do
    @assert_block_via_post.call('invalid', @missing_floorsheet_msg, nil, true)
  end
  test "should not import sales cm without the corresponding floorsheet" do
    @assert_block_via_post.call('invalid', @missing_floorsheet_msg, nil)
  end


  # explicit invalid files
  test "should not import invalid sales cm: missing settlement id" do
    # The missing floorsheet error message because settlement id column is not explicitly checked
    @assert_block_via_post.call('invalid', @missing_floorsheet_msg, 1)
  end
  test "should not import invalid sales cm: multiple settlements" do
    @assert_block_via_post.call('invalid', 'the file you have uploaded has multiple settlement ids', 2)
  end
  test "should not import invalid sales cm: trade date missing" do
    @assert_block_via_post.call('invalid', 'please upload a correct file. trade date is missing', 3)
  end
  test "should not import invalid sales cm: missing contract number" do
    @assert_block_via_post.call('invalid', @missing_contract_number_msg, 4)
  end
  test "should not import invalid sales cm: missing header rows" do
    # Contract number column check hits first
    @assert_block_via_post.call('invalid', @missing_contract_number_msg, 5)
  end
  test "should not import invalid sales cm: missing data rows" do
    # Contract number column check hits first
    @assert_block_via_post.call('invalid', @missing_contract_number_msg, 6)
  end
  test "should not import invalid sales cm: blank" do
    # Contract number column check hits first
    @assert_block_via_post.call('invalid', @missing_contract_number_msg, 7)
  end
end
