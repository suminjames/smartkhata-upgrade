require 'test_helper'

class Files::OrdersControllerTest < ActionController::TestCase
  @@file_type = FileUpload::file_types[:orders]

  def setup
    sign_in users(:user)
    # AR::Relation object which can be RELOADED!
    @file_uploads = FileUpload.where(file_type: @@file_type)
    @assert_block_via_get = lambda { | action, title |
      get action
      assert_response :success
      assert_template "files/orders/#{action}"
      assert_select "h2.section-title", title
      assert_not_nil assigns(:file_list)
    }
    @post_action = proc { | file_path, format |
      format ||= 'text/xls'
      fixture_file_path = "files/#{file_path}"
      post :import, file: fixture_file_upload(fixture_file_path, format)
    }
    @assert_block_via_invalid_post = proc { | error_desc, error_msg |
      file_path = "invalid_files/June30/OrderReport2073-03-16__minified__#{error_desc.gsub ' ', '_'}.xls"
      @post_action.call(file_path)
      assert_redirected_to new_files_order_path
      if error_msg
        assert_equal error_msg, flash[:error]
      else
        assert_not_nil flash[:error]
      end
      get :index
      assert assigns(:file_list).empty?
    }
  end

  test "should get new" do
    @assert_block_via_get.call(:new, 'Upload Order file')
  end

  test "should get index" do
    @assert_block_via_get.call(:index, 'Orders')
  end

  # THIS TEST PASSES/FAILS DEPENDING UPON ITS MOOD!
  # ## Usually fails when run in block
  test "should import valid order once" do
    # New format Nepse order file
    file_path = 'undated/OrderReport2073-03-16__minified.xls'
    @post_action.call(file_path)
    assert_response :success, "##### You may ignore this fail if you ran tests in block! # [2 of 2] #####"
    assert_equal "Successfully uploaded and processed the file.", flash[:notice]
    assert_template 'files/orders/import'
    @file_uploads.reload
    file_count_after_valid_upload = @file_uploads.count
    # Can be multiple reports for multiple dates
    assert file_count_after_valid_upload > 0
    # Same order again
    @post_action.call(file_path)
    assert_not_nil flash[:error]
    # File count unchanged
    @file_uploads.reload
    assert_equal file_count_after_valid_upload, @file_uploads.count
  end

  test "should not import files with invalid names" do
    files = ['BrokerwiseFloorSheetReport 10 May.xls', 'CM0518052016141937.csv']
    file_paths = files.map{|f| "May10/#{f}"}
    file_paths.each do |file|
      @post_action.call(file, "text/#{file[-3..-1]}")
      assert_redirected_to new_files_order_path
      assert_equal "Please Upload a valid file", flash[:error]
      get :index
      assert assigns(:file_list).empty?
    end
  end

  test "should not import order with missing columns" do
    @assert_block_via_invalid_post.call('missing columns',
                                        "One of the rows is invalid! Please upload a valid file.")
  end

  test "should not import order with necessary cells blank" do
    # First catch at row 16!
    @assert_block_via_invalid_post.call('some cells blank',
                                        "Row 16 is invalid! Please upload a valid file.")
  end

  test "should not import order with the wrong sum" do
    @assert_block_via_invalid_post.call('wrong sum',
                                        "The sum of totals of rows doesn't add up to those in grand total row! Please upload a valid file.")
  end

end
