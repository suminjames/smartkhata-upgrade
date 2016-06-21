require 'test_helper'

class Files::CloseoutsControllerTest < ActionController::TestCase
  def setup
    sign_in users(:user)
    @closeout_types = ['credit', 'debit']
    @post_action = lambda { | file_path |
      fixture_file_path = "files/#{file_path}"
      post :import, file: fixture_file_upload(fixture_file_path)
    }
  end

  test "should get new" do
    @closeout_types.each do | closeout_type |
      get :new, type: closeout_type
      assert_response :success
      assert_template "files/closeouts/new"
      assert_equal closeout_type, assigns(:closeout_type)
      assert_select 'h2.section-title', "Upload Close out #{closeout_type.capitalize} file"
    end
  end

=begin
  # No index action!
  # test "should get index" do
  #   @assert_block_via_get.call(:index)
  # end

  # No test file?
  test "should import valid file" do
    @post_action.call('undated/08DPA5UINCREMENTALTEST')
    assert_response :success
    # No flash message implemented here!
    # assert_equal "Successfully uploaded and processed the file.", flash[:notice]
    assert_template 'files/dpa5/import'
    get :index
    assert_not assigns(:file_list).empty?
  end
=end

  test "should not import file with invalid name" do
    @post_action.call('May10/CM0518052016141937.csv')
    # Why no redirect here?
    assert_response :success
    assert_equal "The file you have uploaded is not a valid file", flash[:error]
  end

  # No explicit validity checking in upload closeout service
end