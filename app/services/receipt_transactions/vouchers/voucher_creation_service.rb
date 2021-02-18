require 'net/http'

module ReceiptTransactions
  module Vouchers
    class VoucherCreationService
      include CustomDateModule

      def initialize(params, selected_branch_id, selected_fy_code, current_tenant)
        @selected_branch_id, @selected_fy_code, @current_tenant = selected_branch_id, selected_fy_code, current_tenant
        # set voucher general params
        set_voucher_general_params(params)


        #set voucher creation params
        set_voucher_creation_params(params)

        @voucher,
            @is_payment_receipt,
            @ledger_list_financial,
            @ledger_list_available,
            @default_ledger_id,
            @voucher_type,
            @vendor_account_list,
            @client_ledger_list = ::Vouchers::Setup.new(voucher_type:      @voucher_type,
                                                        client_account_id: @client_account_id,
                                                        # bill_id: @bill_id,
                                                        clear_ledger: @clear_ledger,
                                                        bill_ids:     @bill_ids).voucher_and_relevant(@selected_branch_id, @selected_fy_code)
      end

      def call

        # ignore some validations when the voucher type is sales or purchase
        @is_payment_receipt = false
        # create voucher with the posted parameters
        @voucher         = Voucher.new(get_voucher_details)
        voucher_creation = ::Vouchers::Create.new(voucher_type:            @voucher_type,
                                                  client_account_id:       @client_account_id,
                                                  bill_id:                 @bill_id,
                                                  clear_ledger:            @clear_ledger,
                                                  voucher:                 @voucher,
                                                  bill_ids:                @bill_ids,
                                                  voucher_settlement_type: @voucher_settlement_type,
                                                  group_leader_ledger_id:  @group_leader_ledger_id,
                                                  vendor_account_id:       @vendor_account_id,
                                                  tenant_full_name:        @current_tenant.full_name,
                                                  selected_fy_code:        @selected_fy_code,
                                                  selected_branch_id:      @selected_branch_id,
                                                  current_user:            User.last)

      end

      private

      def branch_id_for_entry(branch_id)
        branch_id.to_i == 0 ? User.last&.branch_id : branch_id
      end

      def set_voucher_general_params(params)
        # get parameters for voucher types and assign it as journal if not available
        @bill_ids     = []
        @voucher_type = params[:TXNID] ? Voucher.voucher_types[:receipt_nchl] : Voucher.voucher_types[:receipt_esewa]
        # client account id ensures the vouchers are on the behalf of the client
        @client_account_id = params[:TXNID] ? get_client_account_id(params[:TXNID]) : get_client_account_id(params[:oid])
        # get bill id if present
        @bill_id           = params[:bill_id].to_i if params[:bill_id].present?
        @bill_ids          = params[:TXNID] ? get_bill_ids(params[:TXNID]) : get_bill_ids(params[:oid])
        # check if clear ledger balance is present
        @clear_ledger = set_clear_ledger
      end

      def set_voucher_creation_params(params)
        @fixed_ledger_id         = params[:fixed_ledger_id].to_i if params[:fixed_ledger_id].present?
        @cheque_number           = params[:cheque_number].to_i if params[:cheque_number].present?
        @voucher_settlement_type = 'default'
        @group_leader_ledger_id  = params[:group_leader_ledger_id].to_i if params[:group_leader_ledger_id].present?
        @vendor_account_id       = params[:vendor_account_id].to_i if params[:vendor_account_id].present?
      end

      def get_receipt_transaction(transaction_id)
        @receipt_transaction = ReceiptTransaction.find_by(transaction_id: transaction_id)
      end

      def get_client_account_id(transaction_id)
        receipt_transaction = get_receipt_transaction(transaction_id)
        receipt_transaction.bills.last.client_account_id
      end

      def get_bill_ids(transaction_id)
        receipt_transaction = get_receipt_transaction(transaction_id)
        receipt_transaction.bill_ids
      end

      def set_clear_ledger
        def set_clear_ledger
          clear_ledger = false
          if params[:clear_ledger].present?
            return true if (params[:clear_ledger] == true || params[:clear_ledger] == 'true')
          end
          clear_ledger
        end
      end

      def with_branch_user_params_receipt_transaction(permitted_params, assign_branch = true)
        branch_id          = branch_id_for_entry(permitted_params[:branch_id])
        _additional_params = {}
        _additional_params.merge!({ branch_id: branch_id }) if assign_branch
        permitted_params.merge!(_additional_params)
      end

      def get_bill_names(bill_ids)
        bills           = Bill.where(id: bill_ids)
        bill_with_names = []
        bills.each do |bill|
          bill_with_names.push("#{bill.fy_code}-#{bill.bill_number}")
        end
        bill_with_names.join(',')
      end

      def get_voucher_details

        client_account = @receipt_transaction.bills.last.client_account

        permitted_params = { "date_bs"                => ad_to_bs(Date.today),
                             "value_date_bs"          => ad_to_bs(Date.today),
                             "desc"                   => "",
                             "particulars_attributes" =>
                                 { "0" => { "ledger_id"        => Ledger.find_by(name: Ledger::INTERNALLEDGERS[7]).id.to_s,
                                            "description"      => "",
                                            "amount"           => @receipt_transaction.amount.to_s,
                                            "transaction_type" => "dr",
                                            "branch_id"        => client_account.branch_id.to_s },
                                   "3" =>
                                       { "ledger_id"                 => client_account.ledger.id.to_s,
                                         "description"               => "",
                                         "amount"                    => @receipt_transaction.amount.to_s,
                                         "transaction_type"          => "cr",
                                         "branch_id"                 => client_account.branch_id.to_s,
                                         "bills_selection"           => @receipt_transaction.bill_ids.join(','),
                                         "selected_bill_names"       => get_bill_names(@receipt_transaction.bill_ids),
                                         "ledger_balance_adjustment" => "" } } }

        with_branch_user_params_receipt_transaction(permitted_params)

      end
    end
  end
end
