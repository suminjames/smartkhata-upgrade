desc "Delete a voucher"
namespace :voucher do
  task :delete, [:tenant, :id] => 'smartkhata:validate_tenant' do |task,args|
    tenant = args.tenant
    vouchers = [args.id]

    voucher = Voucher.where(id: vouchers).first
    raise NotImplementedError unless voucher.present?

    ledgers = Particular.where(voucher_id: vouchers).pluck(:ledger_id).uniq.join(' ')
    particulars = Particular.where(voucher_id: vouchers)
    # right now we are focussed with just two entry receipt payment
    raise NotImplementedError if particulars.count != 2
    ActiveRecord::Base.transaction do

      cheque_entries = voucher.cheque_entries.uniq
      raise NotImplementedError if cheque_entries.count > 1
      cheque_entry = cheque_entries.first
      if cheque_entry
        ChequeEntryParticularAssociation.where(cheque_entry_id: cheque_entry.id).delete_all
        cheque_entry.delete
      end


      settlements= voucher.payment_receipts.uniq
      raise NotImplementedError if settlements.count > 1
      settlement = settlements.first
      amount = 0
      if settlement
        ParticularSettlementAssociation.where(settlement_id: settlement.id).delete_all
        settlement.delete
        amount = settlement.amount
      end

      raise NotImplementedError if voucher.bills.count > 1
      bill = voucher.bills.first
      if bill
        BillVoucherAssociation.where(voucher_id: voucher.id).delete_all
        # since we are considering the case of 2 particular voucher

        raise NotImplementError if amount ==  0
        bill.balance_to_pay += amount
        bill.status = Bill.statuses[:pending]
        bill.save!
      end

      particulars.delete_all
      Voucher.where(id: vouchers).delete_all

      # update the ledgers with new balances
      Rake::Task["ledger:populate_ledger_dailies_selected"].invoke(tenant, ledgers)
      Rake::Task["ledger:populate_closing_balance_selected"].invoke(tenant, ledgers)
    end

  end

  task :delete_simple, [:tenant, :id] => 'smartkhata:validate_tenant' do |task, args|
    tenant = args.tenant
    vouchers = [args.id]
    ledgers = Particular.where(voucher_id: vouchers).pluck(:ledger_id).uniq.join(' ')
    ActiveRecord::Base.transaction do
      Particular.where(voucher_id: vouchers).delete_all
      Voucher.where(id: vouchers).delete_all

      Rake::Task["ledger:populate_ledger_dailies_selected"].invoke(tenant, ledgers)
      Rake::Task["ledger:populate_closing_balance_selected"].invoke(tenant, ledgers)
    end
  end


  task :change_date, [:tenant, :id, :new_date] =>  'smartkhata:validate_tenant' do |task, args|
    include CustomDateModule
    tenant = args.tenant
    abort 'Please voucher' unless args.id.present?
    abort 'Please valid date bs' unless args.new_date.split('-').size == 3

    vouchers = [args.id]
    new_date_bs = args.new_date
    vouchers = Voucher.where(id: vouchers)
    ledgers = Particular.where(voucher_id: vouchers).pluck(:ledger_id).uniq.join(' ')

    ActiveRecord::Base.transaction do
      vouchers.each do |v|
        v.skip_cheque_assign = true
        v.skip_number_assign = true
        v.update_attributes(date: bs_to_ad(new_date_bs), date_bs: new_date_bs)
        v.particulars.update_all(date_bs: new_date_bs, transaction_date:  bs_to_ad(new_date_bs))
        v.payment_receipts.update_all(date: bs_to_ad(new_date_bs), date_bs: new_date_bs)
        v.cheque_entries.update_all(cheque_date: bs_to_ad(new_date_bs))
      end

      Rake::Task["ledger:populate_ledger_dailies_selected"].invoke(tenant, ledgers)
    end
  end
end


822212