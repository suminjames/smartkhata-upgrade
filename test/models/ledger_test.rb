  # == Schema Information
  #
  # Table name: ledgers
  #
  #  id                  :integer          not null, primary key
  #  name                :string
  #  client_code         :string
  #  opening_blnc        :decimal(15, 4)   default(0.0)
  #  closing_blnc        :decimal(15, 4)   default(0.0)
  #  creator_id          :integer
  #  updater_id          :integer
  #  fy_code             :integer
  #  branch_id           :integer
  #  dr_amount           :decimal(15, 4)   default(0.0), not null
  #  cr_amount           :decimal(15, 4)   default(0.0), not null
  #  created_at          :datetime         not null
  #  updated_at          :datetime         not null
  #  group_id            :integer
  #  bank_account_id     :integer
  #  client_account_id   :integer
  #  employee_account_id :integer
  #  vendor_account_id   :integer
  #  opening_balance_org :decimal(15, 4)   default(0.0)
  #  closing_balance_org :decimal(15, 4)   default(0.0)
  #

  # TODO Testings
  # validate :name_from_reserved?, on: :create
  require 'test_helper'

  class LedgerTest < ActiveSupport::TestCase
    attr_accessor :sk_ledger, :ledger_balance
    def setup
      @ledger = ledgers(:one)
      @new_ledger = Ledger.new(name: 'foo', opening_blnc: 500)

      @sk_ledger = create(:ledger)
    end

    test "should be valid" do
      assert @new_ledger.valid?
    end

    test "ledger name should not be blank" do
      @new_ledger.name = '  '
      assert @new_ledger.invalid?
    end

    # test "should store error if ledger name collides with an internal ledger name" do
    #   # Need to add a new ledger "Close Out" in fixtures for this test.(Also update relevant tests eg. basic app flow test)
    #   @new_ledger.name = Ledger::INTERNALLEDGERS[0]
    #   @new_ledger.name_from_reserved?
    #   assert @new_ledger.errors.present?
    # end

    test "opening_balance should not be negative" do
      @new_ledger.opening_blnc = -100_000
      assert @new_ledger.invalid?
    end

    test "should update_closing_balance for debit" do
      initial_opening_balance = @ledger.opening_balance
      assert_equal @ledger.closing_blnc.to_f, 0.0
      @ledger.update_closing_blnc
      @ledger.reload
      assert_equal @ledger.opening_blnc, @ledger.closing_blnc
      assert_equal initial_opening_balance, @ledger.closing_blnc
    end

    test "should update_closing_balance for credit" do
      initial_opening_balance = @ledger.opening_balance
      assert_equal @ledger.closing_blnc.to_f, 0.0
      @ledger.opening_balance_type = Particular.transaction_types['cr']
      @ledger.update_closing_blnc
      @ledger.reload
      assert_equal @ledger.opening_blnc, @ledger.closing_blnc
      assert_equal initial_opening_balance, @ledger.closing_blnc
    end

    test "should store error if negative opening_balance" do
      @ledger.positive_amount
      assert @ledger.errors.none?

      @ledger.opening_blnc = -500
      @ledger.positive_amount
      assert_equal "can't be negative or blank", @ledger.errors[:opening_blnc][0]
    end

    # testing filterrific method
    test "options_for_ledger_select should return appropriate values" do
      params_to_test = [
        nil, #initial state
        {"reset_filterrific"=>"true"}, #when resetting param
        {},
        {"by_ledger_id"=>99999, "by_ledger_type"=>""} #imaginary id
      ]

      # note: assert_empty will fail if nil returned
      params_to_test.each do |param|
        assert_empty Ledger.options_for_ledger_select(param), 'return value not empty when the argument is "#{param.inspect}"'
      end

      # usual hash
      refute_empty Ledger.options_for_ledger_select({"by_ledger_id"=>@ledger.id, "by_ledger_type"=>""})
    end

    # update custom method in ledger.rb
    test "should update ledger with ledger balances" do
      @ledger_balance_org = create(:ledger_balance, ledger_id: @sk_ledger.id, opening_balance: 0, closing_balance: 0)
      params = {
          :name => "tester saroj",
          :group_id =>"1",
          :vendor_account_id =>"",
          :ledger_balances_attributes =>{
              "0"=>{
                  "opening_balance"=>"1000.0",
                  "opening_balance_type"=>"cr",
                  "branch_id"=>"1",
              },
              "1"=>{
                  "opening_balance"=>"400",
                  "opening_balance_type"=>"dr",
                  "branch_id"=>"2"
              }
          }
      }

      UserSession.selected_branch_id =  0
      assert @ledger.update_custom(params)
      assert_equal -600, @ledger.closing_balance.to_f
      UserSession.selected_branch_id = 2
      assert_equal 400, @ledger.closing_balance.to_f
      UserSession.selected_branch_id = 1
      assert_equal -1000, @ledger.closing_balance.to_f
    end

    # update custom method in ledger.rb
    test "should update ledger with initial ledger balances" do


      @ledger_balance = create(:ledger_balance, ledger_id: @sk_ledger.id, opening_balance: 500, closing_balance: 500)
        @ledger_balance_org = create(:ledger_balance, branch_id: nil, ledger_id: @sk_ledger.id, opening_balance: 500, closing_balance: 500)

      params = {
          "name" => "tester saroj",
          "group_id" =>"1",
          "vendor_account_id" =>"",
          "ledger_balances_attributes" =>{
              "0"=>{
                  "opening_balance"=>"1000.0",
                  "opening_balance_type"=>"cr",
                  "branch_id"=>"1",
                  "id"=>"#{@ledger_balance.id}"
              },
              "1"=>{
                  "opening_balance"=>"400",
                  "opening_balance_type"=>"dr",
                  "branch_id"=>"2"
              }
          }
      }
      # convert string keys to hash
      params = params.deep_symbolize_keys
      # make sure there are only 3 ledger balances
      ledger_balance_count = LedgerBalance.unscoped.where(fy_code: 7374, ledger_id: @sk_ledger.id).count

      # edit both is available on all branch
      UserSession.selected_branch_id = 0

      assert @sk_ledger.update_custom(params)

      # assert_equal 3,ledger_balance_count
      assert_equal -600, @sk_ledger.closing_balance.to_f
      UserSession.selected_branch_id = 1
      assert_equal -1000, @sk_ledger.closing_balance.to_f
      UserSession.selected_branch_id = 2
      assert_equal 400, @sk_ledger.closing_balance.to_f
    end


    # by wrong data means ledger balance as negative

    test "should not update ledger with initial ledger balances and wrong data for new balance" do
      @ledger_balance = create(:ledger_balance, ledger_id: @sk_ledger.id, opening_balance: 500, closing_balance: 500)
      @ledger_balance_org = create(:ledger_balance, branch_id: nil, ledger_id: @sk_ledger.id, opening_balance: 500, closing_balance: 500)

      params = {
          "name" => "tester saroj",
          "group_id" =>"1",
          "vendor_account_id" =>"",
          "ledger_balances_attributes" =>{
              "0"=>{
                  "opening_balance"=>"1000.0",
                  "opening_balance_type"=>"cr",
                  "branch_id"=>"1",
                  "id"=>"#{@ledger_balance.id}"
              },
              "1"=>{
                  "opening_balance"=>"-400",
                  "opening_balance_type"=>"dr",
                  "branch_id"=>"2"
              }
          }
      }
      # convert string keys to hash
      params = params.deep_symbolize_keys
      # edit both is available on all branch
      UserSession.selected_branch_id = 0

      # make sure there are only 3 ledger balances
      ledger_balance_count = LedgerBalance.unscoped.where(fy_code: 7374, ledger_id: @sk_ledger.id).count
      refute @sk_ledger.update_custom(params)
      assert_equal ledger_balance_count, 2
      assert_equal 500, @sk_ledger.closing_balance.to_f
    end


    test "should not update ledger with initial ledger balances and wrong data for existing balance" do
      @ledger_balance = create(:ledger_balance, ledger_id: @sk_ledger.id, opening_balance: 500, closing_balance: 500)
      @ledger_balance_org = create(:ledger_balance, branch_id: nil, ledger_id: @sk_ledger.id, opening_balance: 500, closing_balance: 500)

      params = {
          "name" => "tester saroj",
          "group_id" =>"1",
          "vendor_account_id" =>"",
          "ledger_balances_attributes" =>{
              "0"=>{
                  "opening_balance"=>"-1000.0",
                  "opening_balance_type"=>"dr",
                  "branch_id"=>"1",
                  "id"=>"#{@ledger_balance.id}"
              },
              "1"=>{
                  "opening_balance"=>"400",
                  "opening_balance_type"=>"dr",
                  "branch_id"=>"2"
              }
          }
      }
      # convert string keys to hash
      params = params.deep_symbolize_keys
      # edit both is available on all branch
      UserSession.selected_branch_id = 0

      # make sure there are only 3 ledger balances
      ledger_balance_count = LedgerBalance.unscoped.where(fy_code: 7374, ledger_id: @sk_ledger.id).count
      refute @sk_ledger.update_custom(params)
      assert_equal ledger_balance_count, 2
      assert_equal 500, @sk_ledger.closing_balance.to_f
    end


    test "should update opening balance of one branch but not the other when other has closing balance" do
      @ledger_balance = create(:ledger_balance, ledger_id: @sk_ledger.id, opening_balance: 500)
      @ledger_balance_org = create(:ledger_balance, branch_id: nil, ledger_id: @sk_ledger.id, opening_balance: 500)

      @ledger_balance.update(closing_balance: 1000)
      @ledger_balance_org.update(closing_balance: 1000)

      params = {
          "name" => "tester saroj",
          "group_id" =>"1",
          "vendor_account_id" =>"",
          "ledger_balances_attributes" =>{
              "0"=>{
                  "opening_balance"=>"1000.0",
                  "opening_balance_type"=>"dr",
                  "branch_id"=>"2"
              }
          }
      }
      # convert string keys to hash
      params = params.deep_symbolize_keys
      # edit both is available on all branch
      UserSession.selected_branch_id = 2

      # make sure there are only 3 ledger balances
      ledger_balance_count = LedgerBalance.unscoped.where(fy_code: 7374, ledger_id: @sk_ledger.id).count
      assert @sk_ledger.update_custom(params)
      assert_equal ledger_balance_count, 2
      assert_equal 1000, @sk_ledger.opening_balance.to_f
      UserSession.selected_branch_id = 0
      assert_equal 2000, @sk_ledger.closing_balance.to_f
    end
  end
