class ImportCloseOut < ImportFile
  include CommissionModule
  include ShareInventoryModule
  include FiscalYearModule

  attr_reader :branch_id
  def initialize(file, type, current_user, branch_id)
    super(file)
    @closeout_type = type
    @current_user = current_user
    @branch_id = branch_id
  end

  def process
    open_file(@file)
    unless @error_message
      ActiveRecord::Base.transaction do
        @processed_data.each do |hash|
          # break if the net amount will be nil
          # possible only in case of wrong file upload
          # debit means sales
          # credit means purchase
          net_amount = @closeout_type == 'debit' ? hash['CLOSEOUTDBTAMT'] : hash['CLOSEOUTCRAMT']
          if net_amount.blank?
            import_error("The file you have uploaded is not a valid file")
            raise ActiveRecord::Rollback
            break
          end

          # inorder to prevent duplication
          closeout = Closeout.find_or_create_by!(
            contract_number: hash['CONTRACTNUMBER'],
            closeout_type: Closeout.closeout_types[@closeout_type]
          )

          # update the attributes
          closeout.update!(
            settlement_id: hash['SETTLEMENTID'],
            contract_number: hash['CONTRACTNUMBER'],
            seller_cm: hash['SELLERCM'],
            seller_client: hash['SELLERCLIENT'],
            buyer_cm: hash['BUYERCM'],
            buyer_client: hash['BUYERCLIENT'],
            isin: hash['ISIN'],
            scrip_name: hash['SCRIPNAME'],
            quantity: hash['TRADEDQTY'],
            shortage_quantity: hash['SHORTAGEQTY'],
            rate: hash['RATE'],
            net_amount: closeout.debit? ? hash['CLOSEOUTDBTAMT'] : hash['CLOSEOUTCRAMT']
          )

          # calculation based on debit or credit
          transaction = ShareTransaction.includes(:bill).find_by(
            contract_no: closeout.contract_number,
            transaction_type: @closeout_type == 'debit' ? ShareTransaction.transaction_types[:buying] : ShareTransaction.transaction_types[:selling]
          )

          # transaction need to be present
          # if not it implies that closeout was uploaded before uploading floor sheet
          if transaction.nil?
            import_error("Please upload corresponding Floorsheet First")
            raise ActiveRecord::Rollback
            break
          end

          # quantity adjusted already means the file is uploaded already
          # no need to process

          next if transaction.nil? && transaction.raw_quantity == transaction.quantity

          transaction.quantity = transaction.raw_quantity - closeout.shortage_quantity
          # debit is for sales
          if closeout.debit?

            update_share_inventory(transaction.client_account_id, transaction.isin_info_id, closeout.shortage_quantity, current_user, false)

            commission_amount = get_commission_by_rate(transaction.commission_rate, net_amount)
            dp_fee = 0.0
            dp_fee = transaction.dp_fee if transaction.quantity == 0

            closeout_amount = commission_amount + dp_fee + closeout.net_amount
            closeout_ledger = Ledger.find_or_create_by!(name: "Close Out")
            default_bank_purchase = BankAccount.by_branch_id(branch_id).where(default_for_payment: true).first

            if default_bank_purchase.present?
              if default_bank_purchase.ledger.present?
                # update description
                description = "Shortage Amount Dr Settled  (#{closeout.shortage_quantity}*#{closeout.scrip_name}@#{closeout.rate}) "

                date = transaction.date
                # update ledgers value
                voucher = Voucher.create!(date: date, date_bs: ad_to_bs_string(date), branch_id: transaction.branch_id, current_user_id: current_user.id)
                voucher.share_transactions << transaction
                voucher.desc = description
                voucher.complete!
                voucher.save!

                Ledgers::ParticularEntry.new(current_user.id).insert(default_bank_purchase.ledger, voucher, true, closeout_amount, description, branch_id, Time.now.to_date, current_user.id)
                Ledgers::ParticularEntry.new(current_user.id).insert(closeout_ledger.ledger, voucher, false, closeout_amount, description, branch_id, Time.now.to_date, current_user.id)
              end
            else
              import_error("Please assign a default bank account for sales")
              raise ActiveRecord::Rollback
              break
            end
            # credit the close out account and debit the bank account

            # credit is for sales
          else
            import_error("Closeout upload is not implemented properly for sales case. Please contact developer")
            raise ActiveRecord::Rollback
            break
          end
          transaction.save!
        end
      end
    end
  end
end
