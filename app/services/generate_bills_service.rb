# service to create bill and update corressponding ledger for sales transaction
class GenerateBillsService
  include ApplicationHelper


  def initialize(params)
    @sales_settlement = params[:sales_settlement]
  end

  def process
    # hash to store unique bill number for   client && isin
    hash_dp = Hash.new
    # get bill number
    @bill_number = get_bill_number
    fy_code = get_fy_code

    # Begin Transaction
    ActiveRecord::Base.transaction do
      # only generate bill for the transactions which are not soft deleted
      share_transactions = ShareTransaction.where(settlement_id: @sales_settlement.settlement_id, deleted_at: nil)
      share_transactions.each do |transaction|

        # create a custom key to hold the similar isin transaction per user in a same bill
        client_code = transaction.client_account_id
        # script_id = transaction.isin_info_id
        custom_key = (client_code.to_s)
        client_account = transaction.client_account
        commission = transaction.commission_amount
        sales_commission = commission * 0.75
    		tds = commission * 0.75 * 0.15
        company_symbol = transaction.isin_info.isin
        share_quantity = transaction.raw_quantity
        shortage_quantity = transaction.raw_quantity - transaction.quantity
        share_rate = transaction.share_rate



        # check if the hash has value ( bill number) assigned to the custom key
        # if not create a bill and assign its number to the custom key of the hash for further processing
        if hash_dp.has_key?(custom_key)
          # find bill by the bill number
          bill = Bill.find_or_create_by!(bill_number: hash_dp[custom_key], fy_code: fy_code, date: transaction.date)
        else

          hash_dp[custom_key] = @bill_number
          # create a new bill
          bill = Bill.find_or_create_by!(bill_number: @bill_number, fy_code: fy_code, date: transaction.date) do |b|
            b.bill_type = Bill.bill_types['sales']

            # TODO possible error location check
            b.client_name = transaction.client_account.name if !transaction.client_account.nil?
          end
          @bill_number += 1
        end

        # TODO possible error location
        bill.client_account_id = transaction.client_account_id
        bill.share_transactions << transaction
        bill.net_amount += transaction.net_amount
        bill.balance_to_pay = bill.net_amount
        bill.save!

        # create client ledger if not exist

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

        description = "Shares sold (#{share_quantity}*#{company_symbol}@#{share_rate})"

  			# update ledgers value
  			voucher = Voucher.create!(date_bs: ad_to_bs(Time.now))
        voucher.bills_on_creation << bill
        voucher.share_transactions << transaction
        voucher.desc = description
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
        if transaction.closeout_amount.present? && transaction.closeout_amount > 0

          # amount receivable from nepse  =  share value - tds ( 15 % of broker commission ) - sebon fee - nepse commission(25% of broker commission )
          nepse_amount = transaction.closeout_amount - transaction.amount_receivable.abs

          process_accounts(client_ledger,voucher,false,transaction.net_amount,description)
          process_accounts(nepse_ledger,voucher,true,nepse_amount,description)
          process_accounts(tds_ledger,voucher,true,tds,description)
          process_accounts(sales_commission_ledger,voucher,false,sales_commission,description)
          process_accounts(dp_ledger,voucher,false,transaction.dp_fee,description) if transaction.dp_fee  > 0



          description = "Shortage Sales adjustment (#{shortage_quantity}*#{company_symbol}@#{share_rate})"
          voucher = Voucher.create!(date_bs: ad_to_bs(Time.now))
          voucher.share_transactions << transaction
          voucher.desc = description

          closeout_ledger = Ledger.find_or_create_by!(name: "Close Out")
          # credit nepse
          net_adjustment_amount = transaction.closeout_amount
          process_accounts(nepse_ledger,voucher,false,net_adjustment_amount,description)
          process_accounts(closeout_ledger,voucher,true,net_adjustment_amount,description)
          voucher.complete!
          voucher.save!




          voucher = Voucher.create!(date_bs: ad_to_bs(Time.now))
          voucher.share_transactions << transaction
          voucher.desc = description
          process_accounts(closeout_ledger,voucher,false,net_adjustment_amount,description)
          process_accounts(client_ledger,voucher,true,net_adjustment_amount,description)
          voucher.complete!
          voucher.save!



        else
          process_accounts(client_ledger,voucher,false,transaction.net_amount,description)
          process_accounts(nepse_ledger,voucher,true,transaction.amount_receivable,description)
          process_accounts(tds_ledger,voucher,true,tds,description)
          process_accounts(sales_commission_ledger,voucher,false,sales_commission,description)
          process_accounts(dp_ledger,voucher,false,transaction.dp_fee,description) if transaction.dp_fee  > 0
        end

      end
      # mark the sales settlement as complete to prevent future processing
      @sales_settlement.complete!
    end
    true
  end
end
