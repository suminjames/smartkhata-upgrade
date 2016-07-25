require 'test_helper'

class Files::FilesControllerTest < ActionController::TestCase
  # def setup; sign_in users(:user) end

  # testing is_invalid_file method
  test "should check for invalid file by filename" do
    cm_file = fixture_file_upload('files/May10/CM0518052016141937.csv')
    floorsheet_file = fixture_file_upload('files/May10/BrokerwiseFloorSheetReport 10 May.xls')

    assert @controller.is_invalid_file(nil)
    assert @controller.is_invalid_file(cm_file, 'Floorsheet')
    [[cm_file], [cm_file, 'CM05'], [floorsheet_file, 'Floorsheet']].each do |args|
      assert_not @controller.is_invalid_file(*args)
    end
  end

  # testing file_error method
  test "should set error message" do
    message = 'An error occured while loading the previous error!'
    @controller.file_error(message)
    assert_equal message, flash[:error]
    assert assigns(:error)
  end
end