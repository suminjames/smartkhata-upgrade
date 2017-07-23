module Trading
  module ShareTransactions
    class SplitCommissionService

      include CommissionModule
      include CustomDateModule
      include FiscalYearModule

      def process
        ActiveRecord::Base.transaction do
          ShareTransaction.unscoped.find_each do |transaction|
            tds_rate = 0.15
            commission_amount = transaction.commission_amount

            chargeable_by_nepse = nepse_commission_rate(transaction.date) + broker_commission_rate(transaction.date) * tds_rate

            nepse_commission = nepse_commission_rate(transaction.date) * commission_amount
            tds = broker_commission_rate(transaction.date) * tds_rate * commission_amount
            share_amount = transaction.raw_quantity * transaction.share_rate

            nepse_related_share_amount = share_amount
            if share_amount > 5000000
              nepse_related_share_amount = 0
            end

            if transaction.bank_deposit && transaction.bank_deposit != 0
              nepse_deposit = transaction.bank_deposit
            else
              if transaction.selling?
                nepse_deposit = nepse_related_share_amount - tds - nepse_commission - transaction.sebo.to_f - transaction.cgt.to_f - transaction.closeout_amount.to_f
              else
                nepse_deposit = nepse_related_share_amount + tds + nepse_commission + transaction.sebo
              end
            end

            transaction.update_attributes(tds: tds, nepse_commission: nepse_commission, bank_deposit: nepse_deposit)
          end
        end
      end
    end
  end
end