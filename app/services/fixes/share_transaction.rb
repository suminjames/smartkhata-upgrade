module Fixes
  class ShareTransaction
    include ::CommissionModule
    include ::ApplicationHelper

    def self.call(ids)
      new.call(ids)
    end

    attr_reader :purchase_commission_ledger, :sales_commission_ledger, :nepse_ledger, :nepse_sales, :tds_ledger, :dp_ledger, :compliance_ledger, :acting_user, :ledger_ids, :value_dates, :transaction_dates
    def initialize
      @purchase_commission_ledger = Ledger.find_by(name: "Purchase Commission")
      @sales_commission_ledger = Ledger.find_by(name: "Sales Commission")
      @nepse_ledger = Ledger.find_by(name: "Nepse Purchase")
      @nepse_sales = Ledger.find_by(name: "Nepse Sales")
      @tds_ledger = Ledger.find_by(name: "TDS")
      @dp_ledger = Ledger.find_by(name: "DP Fee/ Transfer")
      @compliance_ledger = Ledger.find_by(name:  "Compliance Fee")
      @acting_user = User.first
      @ledger_ids = default_ledgers
      @value_dates =[]
      @transaction_dates =[]
      @bills = []
    end

    def default_ledgers
      @default_ledgers ||=  [purchase_commission_ledger.id, nepse_ledger.id, tds_ledger.id, dp_ledger.id, sales_commission_ledger.id, nepse_sales.id]
    end

    def commission_info_group(date)
      @commission_info ||=  begin
                              {
                                regular: get_commission_info_with_detail(date, :regular),
                                debenture:   get_commission_info_with_detail(date, :debenture),
                                mutual_funds: get_commission_info_with_detail(date, :mutual_funds)
                              }
                            end
    end

    def call(ids)
      ActiveRecord::Base.transaction do
      ::ShareTransaction.where(id: ids).find_each do |x|
      # ::ShareTransaction.where('date > ?',"2020-12-26").where('share_amount > 2500').where(commission_rate: 'flat_10').find_each do |x|
        @bills |= [x.bill_id]

        amount = x.share_amount
        dp = x.dp_fee

        commission_info = commission_info_group(x.date)[x.isin_info.commission_group]
        commission_rate = get_commission_rate(amount, commission_info)
        commission = get_commission_by_rate( commission_rate, amount).round(2)

        nepse = nepse_commission_amount(commission, commission_info)
        broker_purchase_commission = commission - nepse
        sebon = sebo_amount(amount, commission_info)
        tds = broker_purchase_commission * 0.15
        bank_deposit = nepse + tds + sebon + amount

        if x.buying?
          client_dr = nepse + sebon + amount + broker_purchase_commission + dp
          x.update(net_amount: client_dr, commission_amount: commission, commission_rate: commission_rate, sebo: sebon)

          particular = Particular.dr.where(voucher_id: x.voucher_id).where.not(ledger_id: default_ledgers).first

          client_ledger_id = particular.ledger_id
          client_ledger = Ledger.find client_ledger_id
          description = particular.name
          client_branch_id = particular.branch_id
          date = particular.transaction_date
          value_date = particular.value_date
          voucher = x.voucher

          @ledger_ids |= [client_ledger_id]
          @value_dates |=[value_date]
          @transaction_dates |= [date]

          Particular.where(voucher_id: x.voucher_id).delete_all

          process_accounts(client_ledger, voucher, true, client_dr, description, client_branch_id, date, acting_user, value_date)
          process_accounts(tds_ledger, voucher, true, tds, description, client_branch_id, date, acting_user, value_date)
          process_accounts(purchase_commission_ledger, voucher, false, broker_purchase_commission, description, client_branch_id, date, acting_user, value_date)
          process_accounts(dp_ledger, voucher, false, dp, description, client_branch_id, date, acting_user, value_date) if dp > 0
          process_accounts(nepse_ledger, voucher, false, bank_deposit, description,client_branch_id, date, acting_user, value_date)

        elsif x.selling?
          tds_rate = 0.15
          chargeable_on_sale_rate = broker_commission_rate(x.date) * (1 - tds_rate)

          amount_receivable = x.amount_receivable
          client_cr = amount_receivable - (commission * chargeable_on_sale_rate) - dp
          x.update(net_amount: client_cr, commission_amount: commission, commission_rate: commission_rate, sebo: sebon)
          particular = Particular.cr.where(voucher_id: x.voucher_id).where.not(ledger_id: default_ledgers).first

          client_ledger_id = particular.ledger_id
          client_ledger = Ledger.find client_ledger_id
          description = particular.name
          cost_center_id = particular.branch_id
          settlement_date = particular.transaction_date
          value_date = particular.value_date
          voucher = x.voucher

          @ledger_ids |= [client_ledger_id]
          @value_dates |=[value_date]
          @transaction_dates |= [settlement_date]

          Particular.where(voucher_id: x.voucher_id).delete_all

          process_accounts(client_ledger, voucher, false, client_cr, description, cost_center_id, settlement_date, acting_user, value_date)
          process_accounts(nepse_sales, voucher, true, x.amount_receivable, description, cost_center_id, settlement_date, acting_user, value_date)
          process_accounts(tds_ledger, voucher, true, tds, description, cost_center_id, settlement_date, acting_user, value_date)
          process_accounts(sales_commission_ledger, voucher, false, commission, description, cost_center_id, settlement_date, acting_user, value_date)
          process_accounts(dp_ledger, voucher, false, dp, description, cost_center_id, settlement_date, acting_user, value_date) if dp > 0
        end
      end
      end
      fix_bills
      fix_ledger_ids
      fix_interests
    end

    def fix_bills
      Bill.where(id: @bills).find_each do |bill|
        old_net_amount = bill.net_amount
        old_balance_to_pay = bill.balance_to_pay

        net_amount = bill.share_transactions.sum(:net_amount)
        diff = net_amount - old_net_amount
        new_balance = old_balance_to_pay + diff
        status = bill.status

        if equal_amounts?(new_balance, 0)
          status = Bill.statuses[:settled]
        end

        bill.update(net_amount: net_amount, balance_to_pay: new_balance, status: status)
      end
    end

    def fix_ledger_ids
      Branch.pluck(:id).each do |branch_id|
        unless (ledger_ids.blank? || transaction_dates.blank?)
          fy_code = get_fy_code
          ActiveRecord::Base.transaction do
            Ledger.where(id: ledger_ids).find_each do |ledger|
              Accounts::Ledgers::PopulateLedgerDailiesService.new.patch_ledger_dailies(ledger, false, acting_user.id, branch_id, fy_code, transaction_dates )
              Accounts::Ledgers::ClosingBalanceService.new.patch_closing_balance(ledger, all_fiscal_years: false, branch_id: branch_id, fy_code: fy_code, current_user_id: acting_user.id)
            end
          end
        end
      end
    end

    def fix_interests
      value_dates.each do |value_date|
        if (value_date < Time.current.to_date )
          ledger_ids.each do |ledger_id|
            InterestJob.perform_later(ledger_id, value_date.to_s)
          end
        end
      end
    end

  end
end
