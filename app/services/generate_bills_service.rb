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
        script_id = transaction.isin_info_id
        custom_key = (client_code.to_s+'_'+script_id.to_s)
        client_account = transaction.client_account
        commission = transaction.commission_amount
        sales_commission = commission * 0.75
    		tds = commission * 0.75 * 0.15
        company_symbol = transaction.isin_info.isin
        share_quantity = transaction.quantity
        share_rate = transaction.share_rate


        # check if the hash has value ( bill number) assigned to the custom key
        # if not create a bill and assign its number to the custom key of the hash for further processing
        if hash_dp.has_key?(custom_key)
          # find bill by the bill number
          bill = Bill.find_or_create_by!(bill_number: hash_dp[custom_key], fy_code: fy_code)
        else

          hash_dp[custom_key] = @bill_number
          # create a new bill
          bill = Bill.find_or_create_by!(bill_number: @bill_number, fy_code: fy_code) do |b|
            b.bill_type = Bill.bill_types['pay']

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

  			# update ledgers value
  			voucher = Voucher.create!
        # process_accounts(ledger,voucher, is_debit, amount)

        # for a sales
        # client is credited
        # nepse is debited
        # tds is debited
        # sales commission is credited
        # dp is credited

        # TODO replace bill from partiucalr with that in voucher
        description = "as being sold(#{share_quantity}*#{company_symbol}@#{share_rate})"
  		  process_accounts(client_ledger,voucher,false,transaction.net_amount,description,bill.id)
  			process_accounts(nepse_ledger,voucher,true,transaction.amount_receivable,description,bill.id)
  			process_accounts(tds_ledger,voucher,true,tds,description,bill.id)
  			process_accounts(sales_commission_ledger,voucher,false,sales_commission,description,bill.id)
  			process_accounts(dp_ledger,voucher,false,transaction.dp_fee,description,bill.id) if transaction.dp_fee  > 0
      end
      # mark the sales settlement as complete to prevent future processing
      @sales_settlement.complete!
    end
    true
  end
end
