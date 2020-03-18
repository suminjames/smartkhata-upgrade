# service to settle closeout
class ShortageSettlementService
  include ApplicationHelper
  attr_reader :share_transaction, :error, :settlement_by, :balancing_transactions

  SETTLEMENT_TYPES = %w(client broker counter_broker)

  def initialize( transaction, settlement_by, current_tenant, params={})
    @current_user = params[:current_user]
    @branch = params[:branch]
    @share_transaction = transaction
    @error = nil
    @settlement_by = settlement_by
    @balancing_transactions_ids = params[:balancing_transaction_ids]
    @balancing_transactions = ShareTransaction.unscoped.where(id: @balancing_transactions_ids)
    @closeout_quantity = @share_transaction.raw_quantity -  @share_transaction.quantity
    @current_tenant = current_tenant
  end

  def process
    return unless validate?
    ActiveRecord::Base.transaction do
      process_sales_closeout if share_transaction.selling?
      process_buy_closeout if share_transaction.buying?
    end
  end


  def validate?
  #   make sure the the balancing transactions are of same client
    if @share_transaction.closeout_settled
      @error = 'It has already been processed'
      return false
    end
  #   settlement by allowed is only client and broker
    unless SETTLEMENT_TYPES.include?(settlement_by)
      @error = 'This is not a valid request'
      return false
    end

    if share_transaction.buying? && settlement_by != 'client' && @balancing_transactions_ids.empty?
      @error = 'This is not a valid request'
      return false
    end
    if share_transaction.buying? && settlement_by != 'client' && !receipt_bank_account_ledger
      @error = 'Please setup default bank where cds sends shortage amount'
      return false
    end

    if share_transaction.buying? && settlement_by != 'client' && !counter_broker_ledger_mapped?
      @error = 'Please map the broker profile with ledger for the counter broker'
      return false
    end

    # the transactions that balance the closeout should have equal quantity
    if @balancing_transactions_ids.present? && ( balancing_transactions.sum(:quantity) != @closeout_quantity)
      @error = 'This is not a valid request'
      return false
    end
    return true
  end

  def receipt_bank_account_ledger
    BankAccount.default_receipt_account(@branch.id).try(:ledger)
  end


  def counter_broker_ledger
    ledger = nil
    broker_profile = BrokerProfile.english.where(broker_number: @share_transaction.counter_broker ).first
    ledger = broker_profile.ledger if broker_profile
    ledger
  end

  def counter_broker_ledger_mapped?
    (@share_transaction.buyer == @share_transaction.seller) ||  counter_broker_ledger.present?
  end


  def process_sales_closeout
    share_transaction.closeout_settled = true
    bill = share_transaction.bill

    # bill should be present
    (@error = 'Please make sure it is a correct branch';return false) unless bill


    company_symbol = share_transaction.isin_info.isin
    share_rate = share_transaction.share_rate
    client_account = share_transaction.client_account
    client_name = client_account.name
    cost_center_id = client_account.branch_id
    settlement_date = Time.now
    closeout_ledger = Ledger.find_by(name: "Close Out")
    client_ledger = Ledger.find_by(client_code: client_account.nepse_code)

    if settlement_by == 'client'
      bill.net_amount -= share_transaction.closeout_amount
      bill.closeout_charge += share_transaction.closeout_amount
      bill.save!
      description = "Shortage Sales adjustment (#{@closeout_quantity}*#{company_symbol}@#{share_rate}) Transaction number (#{share_transaction.contract_no}) of #{client_name}"
      voucher = Voucher.create!(date: settlement_date, branch_id: @branch.id, creator_id: @current_user.id, updater_id: @current_user.id)
      voucher.desc = description
      process_accounts(closeout_ledger, voucher, false, share_transaction.closeout_amount, description, cost_center_id, settlement_date,@current_user)
      process_accounts(client_ledger, voucher, true, share_transaction.closeout_amount, description, cost_center_id, settlement_date, @current_user)
      voucher.complete!
      voucher.save!
    end
    share_transaction.save!
  end

  def process_buy_closeout
    share_transaction.closeout_settled = true
    bill = share_transaction.bill

    # bill should be present
    (@error = 'Please make sure it is a correct branch';return false) unless bill

    company_symbol = share_transaction.isin_info.isin
    share_rate = share_transaction.share_rate
    client_account = share_transaction.client_account
    client_name = client_account.name
    cost_center_id = client_account.branch_id
    settlement_date = Time.now
    closeout_ledger = Ledger.find_by(name: "Close Out")
    client_ledger = Ledger.find_by(client_code: client_account.nepse_code)

    if settlement_by == 'client'
      bill.net_amount -= share_transaction.closeout_amount
      bill.save!
      description = "Shortage Sales adjustment (#{@closeout_quantity}*#{company_symbol}@#{share_rate}) Transaction number (#{share_transaction.contract_no}) of #{client_name}"
      voucher = Voucher.create!(date: settlement_date, branch_id: @branch.id, creator_id: @current_user.id, updater_id: @current_user.id)
      voucher.desc = description

      process_accounts(receipt_bank_account_ledger, voucher, true, share_transaction.closeout_amount, description, cost_center_id, settlement_date, @current_user)
      process_accounts(closeout_ledger, voucher, false, share_transaction.closeout_amount, description, cost_center_id, settlement_date, @current_user)

      process_accounts(closeout_ledger, voucher, true, share_transaction.closeout_amount, description, cost_center_id, settlement_date, @current_user)
      process_accounts(client_ledger, voucher, false, share_transaction.closeout_amount, description, cost_center_id, settlement_date, @current_user)
      voucher.complete!
      voucher.save!
    end




    if ( settlement_by == 'broker' || settlement_by == 'counter_broker')

      client_nepse_code = 'SKBRKRCLST' if settlement_by == 'broker'
      client_nepse_code = "SKBRKR#{share_transaction.seller}" if settlement_by == 'counter_broker'

      if settlement_by == 'counter_broker'
        account_for_bill = counter_broker_ledger.try(:client_account)
      end

      account_for_bill = ClientAccount.find_or_create_by!(nepse_code: client_nepse_code, branch_id: @branch.id, creator_id: @current_user.id, updater_id: @current_user.id) do |client|
        client.name = @current_tenant.full_name if settlement_by == 'broker'
        client.name = counter_broker_ledger.name if settlement_by == 'counter_broker'
        client.branch = Branch.first
        client.skip_validation_for_system = true
        client.skip_ledger_creation = true
      end

      # make the quantity of the balancing transactions to be zero in case it is paid by broker
      # add the quanity to the client in case it has to be hidden from the client
      # no change in bill
      share_transaction.quantity += @closeout_quantity

      # verify if bill needs to be generated or not
      bill_ids = balancing_transactions.pluck(:bill_id).uniq
      if bill_ids.count == 1
        share_transaction_count = ShareTransaction.unscoped.where(bill_id: bill_ids.first).count
      end

      if bill_ids.count != 1 && share_transaction_count != balancing_transactions.count
        # get the fy_code from sales settlement date
        fy_code = get_fy_code(settlement_date)
        # get bill number
        bill_number = get_bill_number(fy_code)

        new_bill = Bill.unscoped.find_or_create_by!(bill_number: bill_number, fy_code: fy_code, date: settlement_date, client_account_id: account_for_bill.id) do |b|
          b.bill_type = Bill.bill_types['purchase']
          b.client_name = account_for_bill.name
          b.branch_id = cost_center_id
        end
      end

      client_reversal_amount = get_client_reversal_amount(balancing_transactions)

      description = "Bill adjustment for Shortage Sales of (#{@closeout_quantity}*#{company_symbol}@#{share_rate}) Transaction number (#{share_transaction.contract_no}) of #{client_name}"
      voucher = Voucher.create!(date: settlement_date, branch_id: @branch.id, creator_id: @current_user.id, updater_id: @current_user.id)
      voucher.desc = description

      process_accounts(receipt_bank_account_ledger, voucher, true, share_transaction.closeout_amount, description, cost_center_id, settlement_date, @current_user)
      process_accounts(closeout_ledger, voucher, false, share_transaction.closeout_amount, description, cost_center_id, settlement_date, @current_user)
      if (settlement_by == 'counter_broker')
        process_accounts(closeout_ledger, voucher, true, share_transaction.closeout_amount, description, cost_center_id, settlement_date, @current_user)

        if (share_transaction.closeout_amount - client_reversal_amount) != 0
          if (share_transaction.closeout_amount - client_reversal_amount ) > 0.01
            process_accounts(counter_broker_ledger, voucher, false, (share_transaction.closeout_amount - client_reversal_amount ).abs, description, cost_center_id, settlement_date, @current_user)
          else
            process_accounts(counter_broker_ledger, voucher, true, (share_transaction.closeout_amount - client_reversal_amount ).abs, description, cost_center_id, settlement_date, @current_user)
          end
        end
      else
        process_accounts(closeout_ledger, voucher, true, client_reversal_amount, description, cost_center_id, settlement_date, @current_user)
      end
      new_particular = process_accounts(client_ledger, voucher, false, client_reversal_amount, description, cost_center_id, settlement_date, @current_user)
      new_particular.hide_for_client = true
      new_particular.save
      voucher.complete!
      voucher.save!
    end
    share_transaction.save!
  end

  def get_client_reversal_amount(balancing_transactions)
    client_reversal_amount = 0
    balancing_transactions.each do |b|
      # also hide the particular from client for the new transactions.
      b.quantity = 0
      b.save

      if new_bill
        new_bill.share_transactions << b
        new_bill.net_amount += b.net_amount
      else
        bill = b.bill
        bill.client_account_id = account_for_bill.id
        bill.save
      end
      particulars = Particular.unscoped.where(voucher_id: b.voucher_id, ledger_id: client_ledger)
      particulars.update_all(hide_for_client: true)
      client_reversal_amount += particulars.sum(:amount)
    end
    client_reversal_amount
  end
end
