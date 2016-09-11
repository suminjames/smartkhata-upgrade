# service to create bill and update corressponding ledger for sales transaction
class GenerateBillsService
  include ApplicationHelper
  include CommissionModule

  def initialize(params)
    @sales_settlement = params[:sales_settlement]
  end

  def process
    # hash to store unique bill number for   client && isin
    hash_dp = Hash.new

    # Begin Transaction
    ActiveRecord::Base.transaction do
      # only generate bill for the transactions which are not soft deleted
      share_transactions = ShareTransaction.where(settlement_id: @sales_settlement.settlement_id, deleted_at: nil)


      share_transactions.each do |transaction|
        client_code = transaction.client_account_id
        # create a custom key to hold the similar isin transactionp per day per user in a same bill
        custom_key = ("#{client_code.to_s}-#{transaction.date.to_s}")

        client_account = transaction.client_account
        cost_center_id = client_account.branch_id
        commission = transaction.commission_amount
        sales_commission = commission * broker_commission_rate(transaction.date)
        # compliance_fee = compliance_fee(commission, transaction.date)
        tds = commission * broker_commission_rate(transaction.date) * 0.15
        company_symbol = transaction.isin_info.isin
        share_quantity = transaction.quantity
        shortage_quantity = transaction.raw_quantity - transaction.quantity
        share_rate = transaction.share_rate

        charges_of_closeout = (transaction.closeout_amount / 6)

        # get the fy_code from sales settlement date
        fy_code = get_fy_code(transaction.date)
        # get bill number
        bill_number = get_bill_number(fy_code)


        # check if the hash has value ( bill number) assigned to the custom key
        # if not create a bill and assign its number to the custom key of the hash for further processing
        # if the transaction has no quantity (after closeout) dont create bill
        if transaction.quantity > 0
          if transaction.bill_id.present?
            bill = transaction.bill
            if bill.provisional?
              bill.status = :pending
              bill.net_amount = 0.0
            end
          elsif hash_dp.key?(custom_key)
            # find bill by the bill number
            bill = Bill.unscoped.find_or_create_by!(bill_number: hash_dp[custom_key], fy_code: fy_code, date: transaction.date, client_account_id: transaction.client_account_id)
          else
            hash_dp[custom_key] = bill_number
            # create a new bill
            bill = Bill.unscoped.find_or_create_by!(bill_number: bill_number, fy_code: fy_code, date: transaction.date, client_account_id: transaction.client_account_id) do |b|
              b.bill_type = Bill.bill_types['sales']

              # TODO possible error location check
              b.client_name = transaction.client_account.name if !transaction.client_account.nil?
              b.branch_id = cost_center_id
            end
          end

          # TODO possible error location
          bill.share_transactions << transaction

          # bill net amount should consider closeout
          if transaction.closeout_amount.present? && transaction.closeout_amount > 0 && transaction.quantity > 0
            bill.net_amount += ( transaction.net_amount + charges_of_closeout)
          else
            bill.net_amount += transaction.net_amount
          end


          bill.balance_to_pay = bill.net_amount
          bill.sales_settlement_id = @sales_settlement.id
          bill.save!
        end
        # create client ledger if not exist
        # TODO(subas) This should have been an exception
        client_ledger = Ledger.find_or_create_by!(client_code: client_account.nepse_code) do |ledger|
          ledger.name = client_account.name
          ledger.client_account_id =client_account.id
        end

        # assign the client ledgers to group clients
        client_group = Group.find_or_create_by!(name: "Clients")
        client_group.ledgers << client_ledger

        # find or create predefined ledgers
        sales_commission_ledger = Ledger.find_or_create_by!(name: "Sales Commission")
        nepse_ledger = Ledger.find_or_create_by!(name: "Nepse Sales")
        tds_ledger = Ledger.find_or_create_by!(name: "TDS")
        dp_ledger = Ledger.find_or_create_by!(name: "DP Fee/ Transfer")
        # compliance_ledger = Ledger.find_or_create_by!(name: "Compliance Fee")

        description = "Shares sold (#{share_quantity}*#{company_symbol}@#{share_rate})"

        # update ledgers value
        voucher = Voucher.create!(date: transaction.date)
        voucher.bills_on_creation << bill if bill.present?
        voucher.share_transactions << transaction
        voucher.desc = description
        voucher.branch_id = cost_center_id
        voucher.complete!
        voucher.save!

        # process_accounts(ledger,voucher, is_debit, amount)

        # for a sales
        # client is credited
        # nepse is debited
        # tds is debited
        # sales commission is credited
        # dp is credited

        # TODO replace bill from particular with that in voucher
        # closeout amout is positive meaning there is a closeout on sales
        # closeout on buy is handled on deal cancel
        if transaction.closeout_amount.present? && transaction.closeout_amount > 0
          # it depends who will pay client or broker himself

          # if quantity is zero meaning all transaction is shorted all the amount is moved to closeout
          # else partial amount is moved to closeout


          if transaction.quantity > 0
            payable_to_client = transaction.net_amount + charges_of_closeout
            nepse_adjustment = transaction.amount_receivable + charges_of_closeout

            # Note all the commision amount is paid by client here
            process_accounts(client_ledger, voucher, false, payable_to_client, description, cost_center_id, transaction.date)
            process_accounts(nepse_ledger, voucher, true, nepse_adjustment, description, cost_center_id, transaction.date)
            # process_accounts(compliance_ledger, voucher, true, compliance_fee, description, cost_center_id, transaction.date) if compliance_fee > 0
            process_accounts(tds_ledger, voucher, true, tds, description, cost_center_id, transaction.date)
            process_accounts(sales_commission_ledger, voucher, false, sales_commission, description, cost_center_id, transaction.date)
            process_accounts(dp_ledger, voucher, false, transaction.dp_fee, description, cost_center_id, transaction.date) if transaction.dp_fee > 0
          end

          description = "Shortage Sales adjustment (#{shortage_quantity}*#{company_symbol}@#{share_rate}) Transaction number (#{transaction.contract_no})"
          voucher = Voucher.create!(date: transaction.date)
          voucher.share_transactions << transaction
          voucher.desc = description

          closeout_ledger = Ledger.find_or_create_by!(name: "Close Out")

          # closeout credit to nepse
          if transaction.quantity > 0
            process_accounts(nepse_ledger, voucher, false, charges_of_closeout, description, cost_center_id, transaction.date)
            process_accounts(closeout_ledger, voucher, true, charges_of_closeout, description, cost_center_id, transaction.date)
          else
            process_accounts(closeout_ledger, voucher, true, transaction.net_amount.abs, description, cost_center_id, transaction.date)
            process_accounts(nepse_ledger, voucher, false, transaction.amount_receivable.abs, description, cost_center_id, transaction.date)
            process_accounts(tds_ledger, voucher, true, tds, description, cost_center_id, transaction.date)
            process_accounts(sales_commission_ledger, voucher, false, sales_commission, description, cost_center_id, transaction.date)
            process_accounts(dp_ledger, voucher, false, transaction.dp_fee, description, cost_center_id, transaction.date) if transaction.dp_fee > 0
          end

          voucher.complete!
          voucher.save!

        else
          process_accounts(client_ledger, voucher, false, transaction.net_amount, description, cost_center_id, transaction.date)
          process_accounts(nepse_ledger, voucher, true, transaction.amount_receivable, description, cost_center_id, transaction.date)
          # process_accounts(compliance_ledger, voucher, true, compliance_fee, description, cost_center_id, transaction.date) if compliance_fee > 0
          process_accounts(tds_ledger, voucher, true, tds, description, cost_center_id, transaction.date)
          process_accounts(sales_commission_ledger, voucher, false, sales_commission, description, cost_center_id, transaction.date)
          process_accounts(dp_ledger, voucher, false, transaction.dp_fee, description, cost_center_id, transaction.date) if transaction.dp_fee > 0

          # in case of sales transaction greater than 5000000 it has to be settled seperately
          # not with nepse
          if transaction.share_amount > 5000000
            description = "Sales Adjustment with Other Broker (#{share_quantity}*#{company_symbol}@#{share_rate})"
            voucher = Voucher.create!(date: transaction.date)
            voucher.share_transactions << transaction
            voucher.desc = description

            clearing_ledger = Ledger.find_or_create_by!(name: "Clearing Account")
            # credit nepse
            net_adjustment_amount = transaction.share_amount
            process_accounts(nepse_ledger, voucher, false, net_adjustment_amount, description, cost_center_id, transaction.date)
            process_accounts(clearing_ledger, voucher, true, net_adjustment_amount, description, cost_center_id, transaction.date)
            voucher.complete!
            voucher.save!
          end
        end
      end
      # mark the sales settlement as complete to prevent future processing
      @sales_settlement.complete!
    end
    true
  end
end
