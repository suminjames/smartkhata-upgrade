module ReceiptTransactions
  module Vouchers
    class VoucherCreationService
      include CustomDateModule

      def initialize(params, selected_branch_id, selected_fy_code, current_tenant)
        @selected_branch_id, @selected_fy_code, @current_tenant = selected_branch_id, selected_fy_code, current_tenant

        # set voucher general params
        set_voucher_general_params(params)
      end

      def call
        @voucher = Voucher.new(get_voucher_details)
        ::Vouchers::Create.new(voucher_type:            @voucher_type,
                               client_account_id:       @client_account.id,
                               voucher:                 @voucher,
                               bill_ids:                @bill_ids,
                               voucher_settlement_type: 'default',
                               tenant_full_name:        @current_tenant.full_name,
                               selected_fy_code:        @selected_fy_code,
                               selected_branch_id:      @selected_branch_id,
                               current_user:            User.sys_admin&.first&.id)
      end

      private

      def set_voucher_general_params(params)
        @receipt_transaction = params[:TXNID] ? get_receipt_transaction(params[:TXNID]) : get_receipt_transaction(params[:oid])
        # get parameters for voucher types and assign it as journal if not available
        @bill_ids     = []
        @voucher_type = params[:TXNID] ? Voucher.voucher_types[:receipt_nchl] : Voucher.voucher_types[:receipt_esewa]
        # client account id ensures the vouchers are on the behalf of the client
        @client_account   = @receipt_transaction.bills.last.client_account
        @client_branch_id = @client_account.branch_id.to_s
        @bill_ids         = @receipt_transaction.bill_ids
      end

      def get_receipt_transaction(transaction_id)
        ReceiptTransaction.find_by(transaction_id: transaction_id)
      end

      def get_bill_names(bill_ids)
        bills = Bill.find_not_settled.where(id: bill_ids)
        bills.map { |bill|
          "#{bill.fy_code}-#{bill.bill_number}"
        }.join(',')
      end

      def get_voucher_details
        amount   = @receipt_transaction.amount
        bill_ids = @receipt_transaction.bill_ids

        bank_accounts_in_branch = BankAccount.by_branch_id(@selected_branch_id)

        default_for_nchl_receipt_bank_account_in_branch  = bank_accounts_in_branch.by_default_nchl_receipt
        default_for_esewa_receipt_bank_account_in_branch = bank_accounts_in_branch.by_default_esewa_receipt

        dr_ledger_id = if @receipt_transaction.nchl?
                         default_for_nchl_receipt_bank_account_in_branch.present? ? default_for_nchl_receipt_bank_account_in_branch.ledger.id : BankAccount.by_default_nchl_receipt.ledger.id
                       elsif @receipt_transaction.esewa?
                         default_for_esewa_receipt_bank_account_in_branch.present? ? default_for_esewa_receipt_bank_account_in_branch.ledger.id : BankAccount.by_default_esewa_receipt.ledger.id
                       end

        {
          "date_bs"                => ad_to_bs(Date.today),
          "value_date_bs"          => ad_to_bs(Date.today),
          "desc"                   => "",
          "receipt_transaction_id" => @receipt_transaction.id.to_s,
          "particulars_attributes" =>
            [{ "ledger_id"        => dr_ledger_id,
               "description"      => "",
               "amount"           => amount,
               "transaction_type" => "dr",
               "branch_id"        => @client_branch_id
             },
             { "ledger_id"                 => @client_account.ledger.id.to_s,
               "description"               => "",
               "amount"                    => amount,
               "transaction_type"          => "cr",
               "branch_id"                 => @client_branch_id,
               "bills_selection"           => bill_ids.join(','),
               "selected_bill_names"       => get_bill_names(bill_ids),
               "ledger_balance_adjustment" => ""
             }],
          "branch_id"              => @client_branch_id,
          "current_user_id"        => User.sys_admin&.first&.id
        }

      end
    end
  end
end
