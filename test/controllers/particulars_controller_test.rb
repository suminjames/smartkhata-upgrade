require 'test_helper'

class ParticularsControllerTest < ActionController::TestCase
  setup do
    sign_in users(:user)
    @particular = particulars(:one)
    @ledger = ledgers(:one)

    set_fy_code_and_branch_from @particular
  end

# A particular will not have get index.
# They will be seen as children of a ledger.
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:particulars)
  end

# Creation of particular takes place as a subset of voucher instead.
  test "should get new" do
    get :new
    assert_response :success
  end

# Creation or updating of particular not permitted from controller!
# (particular creation takes place as a subset of voucher instead.)
  test "should not create particular" do
    assert_no_difference 'Particular.count' do
      post :create, particular: { }, ledger: @ledger
    end
    assert_response :success
  end
# A particular should not be updated.
  test "should not update particular" do
    patch :update, id: @particular, particular: {  }, ledger: @ledger
    assert_response :success
    @particular.reload
    assert_not_equal @particular.ledger, @ledger
  end


# A particular will not have a separate 'show'.
# It is instead shown via ledgers only.
  test "should show particular" do
    get :show, id: @particular
    assert_response :success
  end

# A particular should not be edited.
  test "should get edit" do
    get :edit, id: @particular
    assert_response :success
  end

# Deletion of particular is forbidden.
  test "should destroy particular" do
    deletable_particular = particulars(:two)
    assert_difference 'Particular.count', -1 do
      delete :destroy, id: deletable_particular
    end
    assert_redirected_to particulars_path
  end
end
