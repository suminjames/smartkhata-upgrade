require 'test_helper'

class BrokerProfilesControllerTest < ActionController::TestCase
  setup do
    @broker_profile = broker_profiles(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:broker_profiles)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create broker_profile" do
    assert_difference('BrokerProfile.count') do
      post :create, broker_profile: { address: @broker_profile.address, broker_name: @broker_profile.broker_name, broker_number: @broker_profile.broker_number, dp_code: @broker_profile.dp_code, email: @broker_profile.email, fax_number: @broker_profile.fax_number, locale: @broker_profile.locale, pan_number: @broker_profile.pan_number, phone_number: @broker_profile.phone_number, profile_type: @broker_profile.profile_type }
    end

    assert_redirected_to broker_profile_path(assigns(:broker_profile))
  end

  test "should show broker_profile" do
    get :show, id: @broker_profile
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @broker_profile
    assert_response :success
  end

  test "should update broker_profile" do
    patch :update, id: @broker_profile, broker_profile: { address: @broker_profile.address, broker_name: @broker_profile.broker_name, broker_number: @broker_profile.broker_number, dp_code: @broker_profile.dp_code, email: @broker_profile.email, fax_number: @broker_profile.fax_number, locale: @broker_profile.locale, pan_number: @broker_profile.pan_number, phone_number: @broker_profile.phone_number, profile_type: @broker_profile.profile_type }
    assert_redirected_to broker_profile_path(assigns(:broker_profile))
  end

  test "should destroy broker_profile" do
    assert_difference('BrokerProfile.count', -1) do
      delete :destroy, id: @broker_profile
    end

    assert_redirected_to broker_profiles_path
  end
end
