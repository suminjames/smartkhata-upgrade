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

      share_transactions = ShareTransaction.where(settlement_id: @sales_settlement.settlement_id)
      share_transactions.each do |transaction|

        # create a custom key to hold the similar isin transanction per user in a same bill
        client_code = transaction.client_account_id
        script_id = transaction.isin_info_id
        custom_key = (client_code.to_s+'_'+script_id.to_s)

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
        bill.save!
      end
      # mark the sales settlement as complete to prevent future processing
      @sales_settlement.complete!
    end
    true
  end
end
