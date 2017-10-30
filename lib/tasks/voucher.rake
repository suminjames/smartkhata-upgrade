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
      branch_id = Voucher.where(id: vouchers).first.branch_id
      fy_code = Voucher.where(id: vouchers).first.fy_code
      Rake::Task["ledger:populate_ledger_dailies_selected"].invoke(tenant, ledgers, branch_id, fy_code)
      Rake::Task["ledger:populate_closing_balance_selected"].invoke(tenant, ledgers,  branch_id, fy_code)
    end

  end

  task :delete_simple, [:tenant, :id] => 'smartkhata:validate_tenant' do |task, args|
    tenant = args.tenant
    vouchers = [args.id]
    ledgers = Particular.where(voucher_id: vouchers).pluck(:ledger_id).uniq.join(' ')
    ActiveRecord::Base.transaction do
      Particular.where(voucher_id: vouchers).delete_all
      branch_id = Voucher.where(id: vouchers).first.branch_id
      fy_code = Voucher.where(id: vouchers).first.fy_code
      Voucher.where(id: vouchers).delete_all
      Rake::Task["ledger:populate_ledger_dailies_selected"].invoke(tenant, ledgers, branch_id, fy_code)
      Rake::Task["ledger:populate_closing_balance_selected"].invoke(tenant, ledgers,  branch_id, fy_code)
    end
  end


  task :change_date, [:tenant, :id, :new_date] =>  'smartkhata:validate_tenant' do |task, args|
    include CustomDateModule
    tenant = args.tenant
    abort 'Please voucher' unless args.id.present?
    abort 'Please valid date bs' unless args.new_date.split('-').size == 3

    voucher_ids = [args.id]
    new_date_bs = args.new_date
    vouchers = Voucher.where(id: voucher_ids)
    ledgers = Particular.where(voucher_id: voucher_ids).pluck(:ledger_id).uniq.join(' ')

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

  task :fix_large_transactions, [:tenant, :fy_code] => 'smartkhata:validate_tenant' do |tasks, args|
    fy_code = args.fy_code
    particulars = Particular.dr.where(ledger_id: 4, amount: 5000000).where(fy_code: fy_code)

    voucher_ids = particulars.pluck(:voucher_id)
    count = 0
    Voucher.where(id: voucher_ids).find_each do |v|
      bills = v.bills.includes(:share_transactions).where('share_transactions.share_amount > 5000000').references('share_transactions')
      if bills.size != 1
        puts 'wrong calculation'
      end

      if bills.size == 1
        share_transactions = bills.first.share_transactions.where('share_transactions.share_amount >= 5000000')
        if share_transactions.size != 1
          puts v.id
        else
          share_amount  = share_transactions.first.share_amount

          if share_amount > 0
            particulars_to_change = v.particulars.where(amount: 5000000)
            if particulars_to_change.dr.first.ledger_id != 4 || particulars_to_change.cr.first.ledger_id != 6
              puts 'something seriously wrong here'
            else
              count += 1
              particulars_to_change.update_all(amount: share_amount)
            end
          else
            puts 'wrong again'
          end
        end
      end
    end
    puts particulars.size
    puts "#{count} patched"
  end

  task :client_info_sales_purchase, [:tenant, :fy_code, :start_date] => 'smartkhata:validate_tenant' do |tasks, args|
    abort 'Please fy code' unless args.fy_code.present?

    [4, 5].each do |ledger_id|
      particulars = Particular.unscoped.where(fy_code: args.fy_code, ledger_id: ledger_id)

      if args.start_date.present?
        particulars = particulars.where('transaction_date >=  ?', args.start_date)
        # particulars = particulars.where('transaction_date =  ', '2016-07-17')
      end

      particulars =  ledger_id == 4 ? particulars.cr : particulars.dr

      particulars.find_each do |particular|
        client_names = particular.bills.pluck(:client_name).uniq
        if client_names.size != 1
          bill_ids = BillVoucherAssociation.where(voucher_id:  particular.voucher.id).pluck(:bill_id)
          client_names = Bill.unscoped.where(id: bill_ids).pluck(:client_name).uniq
        end
        if client_names.size != 1
          puts particular.id
          puts client_names
        else
          name = particular.name << " for #{client_names.first.humanize}"
          particular.update_attribute(:name, name)
        end
      end
    end
  end
end