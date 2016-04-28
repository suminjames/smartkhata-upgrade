class ImportCloseOut < ImportFile

  include CommissionModule
  include ShareInventoryModule

	def initialize(file,type)
    super(file)
    @closeout_type = type
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
          unless net_amount.present?
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
              transaction_type: @closeout_type == 'debit' ? ShareTransaction.transaction_types[:buy] : ShareTransaction.transaction_types[:sell]

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

          unless transaction.nil? && transaction.raw_quantity == transaction.quantity
            transaction.quantity = transaction.raw_quantity - closeout.shortage_quantity
            # debit is for sales
            if closeout.debit?

              update_share_inventory(transaction.client_account_id,transaction.isin_info_id, closeout.shortage_quantity, false)

              commission_amount = get_commission_by_rate(transaction.commission_rate, net_amount)
              dp_fee = 0.0
              if transaction.quantity == 0
                dp_fee = transaction.dp_fee
              end

              closeout_amount = commission_amount + dp_fee + closeout.net_amount
              closeout_ledger = Ledger.find_or_create_by!(name: "Close Out")
              default_bank_purchase = BankAccount.where(:default_for_purchase   => true).first


              if default_bank_purchase.present?
                if default_bank_purchase.ledger.present?
                  # update description
                  description = "Shortage Amount Dr Settled  (#{closeout.shortage_quantity}*#{closeout.scrip_name}@#{closeout.rate}) "
                  # update ledgers value
                  voucher = Voucher.create!(date_bs: ad_to_bs(Time.now))
                  voucher.share_transactions << transaction
                  voucher.desc = description
                  voucher.complete!
                  voucher.save!

                  process_accounts(default_bank_purchase.ledger,voucher,true,closeout_amount,description)
                  process_accounts(closeout_ledger,voucher,false,closeout_amount,description)

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
end