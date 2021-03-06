# service to create bill and update corressponding ledger for sales transaction
class GenerateBillsService
  include ApplicationHelper
  include CommissionModule

  def initialize(params)
    @current_user = params[:current_user]
    @nepse_settlement = params[:nepse_settlement]
    @current_tenant = params[:current_tenant]

    # cases when bills can be generated using the transaction numbers
    @manual = params[:manual] || false
    @contract_numbers = params[:contract_numbers]
    @skip_voucher = params[:skip_voucher] || false
    @bill_ids = params[:bill_ids] || []
  end

  def get_share_transactions
    if @manual
      raise NotImplementedError if @contract_numbers.blank?
      share_transactions = ShareTransaction.where(contract_no: @contract_numbers)
      raise NotImplementedError if share_transactions.pluck(:settlement_id).uniq.count != 1
      raise NotImplementedError if share_transactions.where.not(bill_id: nil).count > 0
      return share_transactions
    else
      return ShareTransaction.where(settlement_id: @nepse_settlement.settlement_id, deleted_at: nil).includes([:client_account, :isin_info])
    end
  end

  def valid_date? date_string
    Date.valid_date? *date_string.split('-').map(&:to_i)
  end

  def get_settlement_date transaction
    if @manual
      nepse_settlement_type = transaction.selling? ? 'NepseSaleSettlement' : 'NepsePurchaseSettlement'
      @nepse_settlement  = nepse_settlement_type.constantize.where(settlement_id: transaction.settlement_id).first
      raise NotImplementedError if @nepse_settlement.blank?
    end
    return @nepse_settlement.settlement_date
  end

  def process
    # hash to store unique bill number for   client && isin
    hash_dp = Hash.new
    # Begin Transaction
    ActiveRecord::Base.transaction do
      # only generate bill for the transactions which are not soft deleted
      share_transactions = get_share_transactions


      share_transactions.each do |transaction|
        settlement_date = get_settlement_date(transaction)
        client_code = transaction.client_account_id
        # create a custom key to hold the similar isin transactionp per day per user in a same bill
        custom_key = ("#{client_code.to_s}-#{transaction.date.to_s}")

        client_account = transaction.client_account

        cost_center_id = client_account.branch_id
        commission = transaction.commission_amount
        sales_commission = commission * broker_commission_rate(transaction.date)
        # compliance_fee = compliance_fee(commission, transaction.date)
        tds = commission * broker_commission_rate(transaction.date) * 0.15

        share_quantity = transaction.raw_quantity


        # default date is T+3 of transaction date
        settlement_date ||= Calendar::t_plus_3_working_days(transaction.date)

        # get the fy_code from sales settlement date
        fy_code = get_fy_code(settlement_date)
        # get bill number
        bill_number = get_bill_number(fy_code)



        if (@manual && (transaction.net_amount + sales_commission + transaction.dp_fee - transaction.amount_receivable - tds - transaction.closeout_amount).abs > 0.01 )
          transaction = fix_amount_receivable transaction
        end
        # raise error when them amounts dont match up
        # A voucher should always equal dr and cr particular amounts
        raise NotImplementedError if (transaction.net_amount + sales_commission + transaction.dp_fee - transaction.amount_receivable - tds - transaction.closeout_amount).abs > 0.01

        # check if the hash has value ( bill number) assigned to the custom key
        # if not create a bill and assign its number to the custom key of the hash for further processing

        if transaction.bill_id.present?
          bill = transaction.bill
          if bill.provisional?
            bill.status = :pending
            bill.net_amount = 0.0
            bill.date = settlement_date
          end
        elsif hash_dp.key?(custom_key)
          # find bill by the bill number
          bill = Bill.unscoped.find_or_create_by!(bill_number: hash_dp[custom_key], fy_code: fy_code, date: settlement_date, client_account_id: transaction.client_account_id, creator_id: @current_user.id, updater_id: @current_user.id)
        else
          hash_dp[custom_key] = bill_number
          # create a new bill
          bill = Bill.unscoped.find_or_create_by!(bill_number: bill_number, fy_code: fy_code, date: settlement_date, client_account_id: transaction.client_account_id, creator_id: @current_user.id, updater_id: @current_user.id) do |b|
            b.bill_type = Bill.bill_types['sales']

            # TODO possible error location check
            b.client_name = transaction.client_account.name if !transaction.client_account.nil?
            b.branch_id = cost_center_id
          end
        end


        # TODO possible error location
        bill.share_transactions << transaction

        # bill net amount should consider closeout
        if transaction.closeout_amount.present? && transaction.closeout_amount > 0
          if @current_tenant.closeout_settlement_automatic
            bill.net_amount += (transaction.net_amount - transaction.closeout_amount)
            # since in automatic client pays
            # it makes sense to make entry on the bill part
            bill.closeout_charge += transaction.closeout_amount
          else
            bill.net_amount += transaction.net_amount
          end
        else
          bill.net_amount += transaction.net_amount
        end


        bill.balance_to_pay = bill.net_amount
        bill.nepse_settlement_id = @nepse_settlement.id
        bill.save!

        # dont create vouchers if skip voucher
        unless @manual && @skip_voucher
          @bill_ids |= [bill.id]
        end
      end
      # mark the sales settlement as complete to prevent future processing

      generate_vouchers
      @nepse_settlement.complete!
    end
    true
  end

  def generate_vouchers
    client_group = Group.find_or_create_by!(name: "Clients")
    # find or create predefined ledgers
    sales_commission_ledger = Ledger.find_or_create_by!(name: "Sales Commission")
    nepse_ledger = Ledger.find_or_create_by!(name: "Nepse Sales")
    tds_ledger = Ledger.find_or_create_by!(name: "TDS")
    dp_ledger = Ledger.find_or_create_by!(name: "DP Fee/ Transfer")
    rounding_ledger = Ledger.find_or_create_by!(name: "Rounding Off Difference")


    Bill.where(id: @bill_ids).find_each do |bill|
      client_account = bill.client_account
      settlement_date = bill.date

      # create client ledger if not exist
      # TODO(subas) This should have been an exception
      client_ledger = Ledger.find_or_create_by!(client_account_id: client_account.id) do |ledger|
        ledger.name = client_account.name
        ledger.client_code = client_account.nepse_code
      end
      # assign the client ledgers to group clients
      client_group.ledgers << client_ledger


      transactions = bill.share_transactions.includes(:isin_info).group(:isin_info_id).weighted_average(:share_rate, :raw_quantity)

      description = transactions.map do |st|
        "#{st.quantity}*#{st.isin_info.isin}@#{st.wa_share_rate.round(2)}"
      end.join(',')

      # update description
      description = "Shares Sold (#{description})  for #{client_account.name}"
      cost_center_id = client_account.branch_id


      voucher = Voucher.create!(date: settlement_date, branch_id: cost_center_id, creator_id: @current_user.id, updater_id: @current_user.id)
      voucher.bills_on_creation << bill if bill.present?
      voucher.share_transactions = bill.share_transactions
      voucher.desc = description
      voucher.complete!
      voucher.save!

      # for a sales
      # client is credited
      # nepse is debited
      # tds is debited
      # sales commission is credited
      # dp is credited

      tds = transactions.map{|h| h['tds']}.inject(:+).round(2)
      dp = transactions.map{|h| h['dp_fee']}.inject(:+).round(2)
      nepse_commission = transactions.map{|h| h['nepse_commission']}.inject(:+).round(2)
      commission_amount = transactions.map{|h| h['commission_amount']}.inject(:+).round(2)
      amount_receivable = transactions.map{|h| h['amount_receivable']}.inject(:+).round(2)
      closeout_amount = transactions.map{|h| h['closeout_amount']}.inject(:+).round(2)
      sales_commission = commission_amount - nepse_commission

      closeout_transactions = []
      # incase of automatic closeout
      # closeout charge is included on bill and charged to client
      # other cases bill doesnt hold the closeout amount
      bill_net_amount = bill.rounded_net_amount
      if @current_tenant.closeout_settlement_automatic
        rounding = amount_receivable + tds- sales_commission - dp  - bill_net_amount
        payable_to_client =  bill_net_amount + closeout_amount
      else
        rounding = amount_receivable + closeout_amount + tds - sales_commission - dp - bill_net_amount
        payable_to_client =  bill_net_amount
      end

      if closeout_amount > 0
        closeout_transactions = bill.share_transactions.where.not(closeout_amount: 0)
      end

      if(rounding.abs != 0)
        process_accounts(rounding_ledger, voucher, rounding < 0, rounding.abs, description, cost_center_id, settlement_date, @current_user, settlement_date)
      end

      process_accounts(dp_ledger, voucher, false, dp, description, cost_center_id, settlement_date, @current_user, settlement_date) if dp > 0
      process_accounts(tds_ledger, voucher, true, tds, description, cost_center_id, settlement_date, @current_user, settlement_date)
      process_accounts(sales_commission_ledger, voucher, false, sales_commission, description, cost_center_id, settlement_date, @current_user, settlement_date)


      # closeout amount is positive meaning there is a closeout on sales
      # closeout on buy is handled on deal cancel
      if closeout_amount > 0
        # if quantity is zero meaning all transaction is shorted all the amount is moved to closeout
        # else partial amount is moved to closeout
        # in case of zero quantity two vouchers are created.
        closeout_ledger = Ledger.find_or_create_by!(name: "Close Out")

        # Note all the commision amount is paid by client here
        process_accounts(client_ledger, voucher, false, payable_to_client, description, cost_center_id, settlement_date, @current_user, settlement_date)

        # some cases it is negative , like in full closeout
        process_accounts(nepse_ledger, voucher, amount_receivable > 0 ? true : false, amount_receivable.abs, description, cost_center_id, settlement_date, @current_user, settlement_date)

        closeout_transactions.each do |transaction|
          shortage_quantity = transaction.raw_quantity - transaction.quantity
          company_symbol = transaction.isin_info.isin
          share_rate = transaction.share_rate
          client_name = client_account.name
          closeout_amount =  transaction.closeout_amount

          description = "Shortage Sales adjustment (#{shortage_quantity}*#{company_symbol}@#{share_rate}) Transaction number (#{transaction.contract_no}) of #{client_name}"
          process_accounts(closeout_ledger, voucher, true, closeout_amount, description, cost_center_id, settlement_date, @current_user, settlement_date)

          if @current_tenant.closeout_settlement_automatic
            # automatic settlement
            voucher = Voucher.create!(date: settlement_date, branch_id: cost_center_id, creator_id: @current_user.id, updater_id: @current_user.id)
            # voucher.share_transactions << transaction
            voucher.desc = description
            process_accounts(closeout_ledger, voucher, false, closeout_amount, description, cost_center_id, settlement_date, @current_user, settlement_date)
            process_accounts(client_ledger, voucher, true, closeout_amount, description, cost_center_id, settlement_date, @current_user, settlement_date)
            transaction.closeout_settled = true
            transaction.save!
            voucher.complete!
            voucher.save!
          end
        end
      else
        process_accounts(client_ledger, voucher, false, bill_net_amount, description, cost_center_id, settlement_date, @current_user, settlement_date)
        process_accounts(nepse_ledger, voucher, true, amount_receivable, description, cost_center_id, settlement_date, @current_user, settlement_date)
      end
    end
  end

  def fix_amount_receivable(transaction)
    tds_rate = 0.15
    chargeable_on_sale_rate = broker_commission_rate(transaction.date) * (1 - tds_rate)
    amount_receivable = transaction.amount_receivable
    # this is the case for close out
    # calculate the charges
    if transaction.closeout_amount > 0
      transaction.net_amount = amount_receivable - (transaction.commission_amount * chargeable_on_sale_rate) - transaction.dp_fee + transaction.closeout_amount
    else
      transaction.net_amount = amount_receivable - (transaction.commission_amount * chargeable_on_sale_rate) - transaction.dp_fee
    end

    transaction.save!
    transaction
  end
end
