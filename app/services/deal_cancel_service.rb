class DealCancelService
  include ShareInventoryModule
  include ApplicationHelper

  @@approval_action = %w[approve reject]
  attr_reader :error_message, :info_message, :share_transaction, :acting_user

  def initialize(attrs = {})
    @transaction_id = attrs[:transaction_id].to_i
    @approval_action = attrs[:approval_action]
    @share_transaction = nil
    @error_message = nil
    @info_message = nil
    @broker_id = attrs[:broker_code]
    @acting_user = attrs[:current_user]
  end

  def process
    # if approval action is present and the action is other than allowed
    if @approval_action.present? && !@@approval_action.include?(@approval_action)
      @error_message = "The action is not available."
      return
    end

    # based on the condition select share transaction by id
    @share_transaction = if @approval_action.present?
                           ShareTransaction.deal_cancel_pending.find_by(id: @transaction_id)
                         else
                           ShareTransaction.no_deal_cancel.find_by(id: @transaction_id)
                         end
    if @share_transaction.blank?
      @error_message = "The transaction number does not exist in the system or unavailable for action."
      return
    end

    voucher = @share_transaction.voucher
    bill = @share_transaction.bill

    # if approval action is not present
    # it is deal cancel initial process
    if @approval_action.present?
      if @approval_action == "approve"
        if voucher.blank?
          @error_message = "The transaction number could not be cancelled. Contact Support"
          return
        end

        # condition when bill has not been created yet
        if bill.blank?
          ActiveRecord::Base.transaction do
            update_share_inventory(@share_transaction.client_account_id, @share_transaction.isin_info_id, @share_transaction.quantity, acting_user, @share_transaction.buying?, true)
            @share_transaction.quantity = 0
            @share_transaction.transaction_cancel_status = :deal_cancel_complete
            @share_transaction.save!
          end
          @info_message = 'Deal cancel approved successfully.'
          @share_transaction = nil
          return
        end

        ActiveRecord::Base.transaction do
          # settle the bill if the net amount of bill and share transaction net amount is equal
          bill.settled! if (bill.net_amount - @share_transaction.net_amount - 25).abs <= 0.1

          # incase of bill created
          relevant_share_transactions = bill.share_transactions.not_cancelled.where(isin_info_id: @share_transaction.isin_info_id)
          dp_fee_adjustment = 0.0
          total_transaction_count = relevant_share_transactions.length
          dp_fee_adjustment = (25.00 / (total_transaction_count + 1)) if total_transaction_count > 0

          # remove the transacted amount from the share inventory
          update_share_inventory(@share_transaction.client_account_id, @share_transaction.isin_info_id, @share_transaction.quantity, acting_user, @share_transaction.buying?, true)
          # create a new voucher and add the bill reference to it
          date_bs = ad_to_bs_string(@share_transaction.date)
          new_voucher = Voucher.create!(date: @share_transaction.date, date_bs: date_bs, voucher_status: Voucher.voucher_statuses[:complete], branch_id: bill.branch_id, current_user_id: acting_user.id)
          new_voucher.bills_on_settlement << bill

          description = "Deal cancelled(#{@share_transaction.quantity}*#{@share_transaction.isin_info.isin}@#{@share_transaction.share_rate}) of Bill: (#{bill.fy_code}-#{bill.bill_number})"

          client_ledger_id = @share_transaction.client_account.ledger.id

          voucher.particulars.each do |particular|
            _particular = reverse_accounts(particular, new_voucher, description, acting_user, dp_fee_adjustment)

            # assign the client particular to transaction
            @share_transaction.particulars_on_settlement << _particular if particular.ledger_id == client_ledger_id
          end

          @share_transaction.particulars.update_all(hide_for_client: true)
          @share_transaction.quantity = 0
          @share_transaction.transaction_cancel_status = :deal_cancel_complete
          @share_transaction.save!

          # Data migrated from mandala doesn't have transaction_message for share_transactions.
          # Therefore, only change the message if transaction_message is present to avoid error.
          create_sms_result = CreateSmsService.new(broker_code: @broker_code, transaction_message: @share_transaction.transaction_message, transaction_date: @share_transaction.date, bill: bill).change_message if @share_transaction.transaction_message.present?
          @info_message = 'Deal cancel approved successfully.'
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
              dp_fee_per_transaction = dp_fee / total_transaction_count
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
              bill.balance_to_pay += @share_transaction.net_amount
              bill.net_amount += @share_transaction.net_amount
              bill.pending!
            end
            bill.save!
          end

          # Data migrated from mandala doesn't have transaction_message for share_transactions.
          # Therefore, only change the message if transaction_message is present to avoid error.
          create_sms_result = CreateSmsService.new(broker_code: @broker_code, transaction_message: @share_transaction.transaction_message, transaction_date: @share_transaction.date, bill: bill).change_message if @share_transaction.transaction_message.present?
        end
        @info_message = 'Deal cancel rejected successfully.'
        @share_transaction = nil
      end
    else
      # get the particular
      client_ledger_id = @share_transaction.client_account.ledger.id
      particular = voucher.particulars.where(ledger_id: client_ledger_id)

      ActiveRecord::Base.transaction do
        @share_transaction.soft_delete
        @share_transaction.transaction_cancel_status = :deal_cancel_pending

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
              next if transaction == @share_transaction

              transaction.dp_fee += dp_fee_adjustment_per_transaction
              transaction.net_amount += dp_fee_adjustment_per_transaction
              transaction.save!
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

        # Data migrated from mandala doesn't have transaction_message for share_transactions.
        # Therefore, only change the message if transaction_message is present to avoid error.
        create_sms_result = CreateSmsService.new(broker_code: @broker_code, transaction_message: @share_transaction.transaction_message, transaction_date: @share_transaction.date, bill: bill).change_message if @share_transaction.transaction_message.present?
      end
      @info_message = 'Deal cancel queued for approval successfully.'
      @share_transaction = nil
      nil
    end
  end
end
