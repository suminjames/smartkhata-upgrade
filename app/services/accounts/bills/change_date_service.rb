module Accounts
  module Bills
    class ChangeDateService
      include CustomDateModule
      attr_reader :current_date, :new_date, :bill_type, :branch_id, :error_message

      def initialize(current_date, new_date, bill_type: nil, branch_id: nil, fy_code: nil, current_user_id: nil)
        @current_date = current_date
        @new_date = new_date
        @bill_type = bill_type
        @branch_id = branch_id
        @error_message = nil
        @current_user_id = current_user_id
        @fy_code = fy_code
      end

      def process
        validate
        bills = get_bills
        new_date_bs = ad_to_bs(new_date)

        branch_id ||= 0

        affected_dates = bills.pluck(:date).uniq
        affected_dates << new_date

        ActiveRecord::Base.transaction do
          vouchers = bills.map(&:vouchers_on_creation).flatten.uniq
          voucher_ids = vouchers.map(&:id)

          ledger_ids = Particular.where(voucher_id: voucher_ids).pluck(:ledger_id).uniq.join(' ')
          vouchers.each do |v|
            v.skip_cheque_assign = true
            v.skip_number_assign = true
            v.update(date: new_date, date_bs: new_date_bs)
            v.particulars.where(voucher_id: v.id).update_all(date_bs: new_date_bs, transaction_date: bs_to_ad(new_date_bs))
            v.payment_receipts.update_all(date: bs_to_ad(new_date_bs), date_bs: new_date_bs)
            v.cheque_entries.update_all(cheque_date: bs_to_ad(new_date_bs))
          end
          bills.update_all(date: new_date)
          patch_ledger_dailies ledger_ids, branch_id, @fy_code, @current_user_id, affected_dates
        end
        puts "#{bills.size} bill processed"
        true
      end

      def get_bills
        bills_with_branch_id = Bill.unscoped.where(date: current_date).where(branch_id: branch_id)
        branch_with_bill_type = Bill.unscoped.where(date: current_date).where(bill_type: Bill.bill_types[bill_type])
        branch_id.present? ? bills_with_branch_id : branch_with_bill_type
      end

      def patch_ledger_dailies(ledger_ids, branch_id, fy_code, current_user_id, affected_dates)
        branch_ids = branch_id == 0 ? Branch.all.pluck(:id) : [branch_id]

        branch_ids.each do |branch_id|
          Accounts::Ledgers::PopulateLedgerDailiesService.new.process(ledger_ids, current_user_id, false, branch_id, fy_code, affected_dates)
        end
      end

      def validate
        raise "invalid current date, date must be in yyyy-mm-dd format" unless valid_date? current_date
        raise "invalid new date, date must be in yyyy-mm-dd format" unless valid_date? new_date
        raise "invalid bill_type" unless [:purchase, :sales, nil].include? bill_type
      end

      private

      def valid_date?(date_string)
        Date.valid_date?(*date_string.split('-').map(&:to_i))
      end
    end
  end
end
