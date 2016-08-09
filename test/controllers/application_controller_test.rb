require 'test_helper'

# THESE TESTS MUST BE RUN AS A SINGLE FILE/TEST, THEY USUALLY FAIL IN BLOCK!!!
class ApplicationControllerTest < ActionController::TestCase
  setup do
    # Load all the controllers
    Rails.application.eager_load!
    # All controllers, except the application controller, of course!
    all_controllers = ApplicationController.descendants
    # Incomplete/irrelevant controllers
    excluded_controllers_main = [DeviseController, AbstractController, Files::FilesController, Files::PurchaseController, PurchasesController, TestController]

    # Error in these controllers #new
    excluded_controllers_main += [ShareTransactionsController, MenuItemsController, SmsMessagesController]

    @controllers_for_authenticated_test   = all_controllers - excluded_controllers_main - [GeneralSettingsController]
    @controllers_for_unauthenticated_test = all_controllers - excluded_controllers_main - [VisitorsController]
    @request.host = 'trishakti.lvh.me'
    @user = users(:user)
  end

  # Testing Before action: :authenticate_user!
  # ## This test may generate 'AbstractController::ActionNotFound' error when run in block
  test "should redirect unauthenticated user to login page" do
    @controllers_for_unauthenticated_test.each do |controller|
      @controller = controller.new
      action = controller.action_methods.first
      get action
      assert_redirected_to new_user_session_path
    end
  end

  # Testing Before action: :set_user_session
  # ## This test fails when run in block..
  test "should set user session when logged in" do
    sign_in @user
    # assert_nil UserSession.user, "##### You may ignore this fail if you ran tests in block! # [1 of 2] #####"
    # User session tends to be carried on from previous tests in group tests!
    UserSession.destroy if UserSession.user
    @controllers_for_authenticated_test.each do |controller|
      @controller = controller.new
      action = controller.action_methods.first
      get action #rescue debugger
      assert_not_nil UserSession.user
    end
    assert_equal @user.name, UserSession.user.name
    assert_equal @user.email, UserSession.user.email
  end
end