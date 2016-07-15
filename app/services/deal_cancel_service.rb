class DealCancelService
  include ShareInventoryModule
  include ApplicationHelper

  @@approval_action = %w{approve reject}
  attr_reader :error_message, :info_message, :share_transaction

  def initialize(attrs = {})
    @transaction_id = attrs[:transaction_id].to_i
    @approval_action = attrs[:approval_action]
    @share_transaction = nil
    @error_message = nil
    @info_message = nil
    @broker_id = attrs[:broker_code]
  end

  def process
    # if approval action is present and the action is other than allowed
    if @approval_action.present? && !@@approval_action.include?(@approval_action)
      @error_message = "The Action is not available"
      return
    end

    # based on the condition select share transaction by id
    if @approval_action.present?
      @share_transaction = ShareTransaction.deal_cancel_pending.find_by(id: @transaction_id)
    else
      @share_transaction = ShareTransaction.no_deal_cancel.find_by(id: @transaction_id)
    end
    if @share_transaction.blank?
      @error_message = "The Transaction number does not exist in the system or unavailable for action"
      return
    end

    voucher = @share_transaction.voucher
    bill = @share_transaction.bill

    # dont allow to approve deal cancel after starting settlement process
    if bill.present? && !bill.pending?
      @error_message = "Bill associated with the share transaction is already under process or settled"
      return
    end


    # if approval action is not present
    # it is deal cancel initial process
    unless @approval_action.present?
      @share_transaction.soft_delete
      @share_transaction.transaction_cancel_status = :deal_cancel_pending

      # get the particular
      client_ledger_id = @share_transaction.client_account.ledger.id
      particular = voucher.particulars.where(ledger_id: client_ledger_id)

      ActiveRecord::Base.transaction do
        @share_transaction.particulars_on_creation << particular
        # hide the particular for client

        if bill.present?
          # incase of bill created
          relevant_share_transactions = bill.share_transactions.not_cancelled.where(isin_info_id: @share_transaction.isin_info_id)


          dp_fee_adjustment = 0.0
          total_transaction_count = relevant_share_transactions.length

          if total_transaction_count > 1
            dp_fee_adjustment = @share_transaction.dp_fee
            dp_fee_adjustment_per_transaction = dp_fee_adjustment / (total_transaction_count - 1.0)
            relevant_share_transactions.each do |transaction|
              unless transaction == @share_transaction
                transaction.dp_fee += dp_fee_adjustment_per_transaction
                transaction.net_amount += dp_fee_adjustment_per_transaction
                transaction.save!
              end
            end
          end

          # now the bill will have atleast one deal cancelled transaction
          bill.has_deal_cancelled!
          if (bill.net_amount - @share_transaction.net_amount).abs <= 0.1
            bill.balance_to_pay = 0
            bill.net_amount = 0
            bill.pending!
          else
            bill.balance_to_pay -= (@share_transaction.net_amount - dp_fee_adjustment)
            bill.net_amount -= (@share_transaction.net_amount - dp_fee_adjustment)
            bill.pending!
          end
          bill.save!
        end
        # reduce the dp fee and  amount
        @share_transaction.net_amount -= @share_transaction.dp_fee
        @share_transaction.dp_fee = 0
        @share_transaction.save!
        # rewrite the sms message
        create_sms_result = CreateSmsService.new(broker_code: @broker_code, transaction_message: @share_transaction.transaction_message, transaction_date: @share_transaction.date, bill: bill).change_message

      end
      @info_message = 'Deal cancelled succesfully.'
      @share_transaction = nil
      return
    else
      if @approval_action == "approve"
        # condition when bill has not been created yet
        if bill.blank?
          ActiveRecord::Base.transaction do
            update_share_inventory(@share_transaction.client_account_id, @share_transaction.isin_info_id, @share_transaction.quantity, @share_transaction.buying?, true)
            @share_transaction.quantity = 0
            @share_transaction.transaction_cancel_status = :deal_cancel_complete
            @share_transaction.save!
          end
          @info_message = 'Deal cancel approved succesfully.'
          @share_transaction = nil
          return
        end

        ActiveRecord::Base.transaction do
          # settle the bill if the net amount of bill and share transaction net amount is equal
          if (bill.net_amount - @share_transaction.net_amount - 25).abs <= 0.1
            bill.settled!
          end

          # incase of bill created
          relevant_share_transactions = bill.share_transactions.not_cancelled.where(isin_info_id: @share_transaction.isin_info_id)
          dp_fee_adjustment = 0.0
          total_transaction_count = relevant_share_transactions.length
          if total_transaction_count > 0
            dp_fee_adjustment = (25.00/ (total_transaction_count + 1))
          end

          # remove the transacted amount from the share inventory
          update_share_inventory(@share_transaction.client_account_id, @share_transaction.isin_info_id, @share_transaction.quantity, @share_transaction.buying?, true)
          # create a new voucher and add the bill reference to it
          date_bs = ad_to_bs_string(@share_transaction.date)
          new_voucher = Voucher.create!(date: @share_transaction.date, date_bs: date_bs, voucher_status: Voucher.voucher_statuses[:complete])
          new_voucher.bills_on_settlement << bill

          description = "Deal cancelled(#{@share_transaction.quantity}*#{@share_transaction.isin_info.isin}@#{@share_transaction.share_rate}) of Bill: (#{bill.fy_code}-#{bill.bill_number})"

          client_ledger_id = @share_transaction.client_account.ledger.id

          voucher.particulars.each do |particular|
            _particular = reverse_accounts(particular, new_voucher, description, dp_fee_adjustment)

            # assign the client particular to transaction
            if particular.ledger_id == client_ledger_id
              @share_transaction.particulars_on_settlement << _particular
            end
          end

          @share_transaction.particulars.update_all(hide_for_client: true)
          @share_transaction.quantity = 0
          @share_transaction.transaction_cancel_status = :deal_cancel_complete
          @share_transaction.save!

          # rewrite the sms message
          create_sms_result = CreateSmsService.new(broker_code: @broker_code, transaction_message: @share_transaction.transaction_message, transaction_date: @share_transaction.date, bill: bill).change_message
          @info_message = 'Deal cancel approved succesfully.'
        end
      else
        @share_transaction.soft_undelete
        @share_transaction.transaction_cancel_status = :no_deal_cancel
        ActiveRecord::Base.transaction do
          @share_transaction.save!
          if bill.present?
            # incase of bill created
            relevant_share_transactions = bill.share_transactions.not_cancelled.where(isin_info_id: @share_transaction.isin_info_id)
            dp_fee_adjustment = 0.0
            total_transaction_count = relevant_share_transactions.length

            if total_transaction_count > 0
              dp_fee = 25.00
              dp_fee_per_transaction = dp_fee / (total_transaction_count)
              # added back since it was removed when deal was cancelled.
              # @share_transaction.net_amount += dp_fee_per_transaction
              relevant_share_transactions.each do |transaction|
                transaction.net_amount = transaction.net_amount - transaction.dp_fee + dp_fee_per_transaction
                transaction.dp_fee = dp_fee_per_transaction
                transaction.save!
              end
            end

            # now the bill will have atleast one deal cancelled transaction
            bill.has_deal_cancelled! if bill.share_transactions.deal_cancel_pending.size > 1

            if total_transaction_count == 1
              bill.balance_to_pay += @share_transaction.net_amount + dp_fee_per_transaction
              bill.net_amount += @share_transaction.net_amount + dp_fee_per_transaction
              bill.pending!
            else
              # increment net amount
              bill.balance_to_pay += (@share_transaction.net_amount)
              bill.net_amount += (@share_transaction.net_amount)
              bill.pending!
            end
            bill.save!
          end

          create_sms_result = CreateSmsService.new(broker_code: @broker_code, transaction_message: @share_transaction.transaction_message, transaction_date: @share_transaction.date, bill: bill).change_message
        end
        @info_message = 'Deal cancelled Rejected succesfully.'
        @share_transaction = nil
      end
    end
  end
end