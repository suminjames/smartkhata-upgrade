desc "Delete a voucher"
namespace :cheque_entries do
  task :patch, [:tenant, :voucher, :starting_number, :user_id] => 'smartkhata:validate_tenant' do |task,args|
    voucher = Voucher.where(id: args.voucher).first
    current_user_id = args.user_id || User.admin.first.id
    raise NotImplementedError unless voucher.present?
    raise NotImplementedError unless voucher.payment_bank?

    @cheque_number = args.starting_number.to_i
    initial_cheque = ChequeEntry.unassigned.where(cheque_number: @cheque_number).first
    raise NotImplementedError unless initial_cheque.present?
    manual_cheque = true

    @date = DateTime.now
    cheque_entries = []
    raise NotImplementedError if  voucher.particulars.cr.count != 1
    bank_particular =   voucher.particulars.cr.first
    bank_ledger = bank_particular.ledger
    bank_account = bank_ledger.bank_account

    ActiveRecord::Base.transaction do
      voucher.particulars.dr.each do |particular|

        if manual_cheque
          cheque_entry = initial_cheque
          manual_cheque = false
        else
          @cheque_number += 1
          cheque_entry = ChequeEntry.where(bank_account_id: bank_account.id, cheque_number: @cheque_number).first
        end

        cheque_entry.cheque_date = DateTime.now
        cheque_entry.status = ChequeEntry.statuses[:pending_approval]
        cheque_entry.client_account_id = particular.ledger.client_account.id
        cheque_entry.beneficiary_name = particular.ledger.client_account.name.titleize
        cheque_entry.amount = particular.amount
        cheque_entry.current_user_id = current_user_id
        cheque_entry.save!
        cheque_entries << cheque_entry

        particular.cheque_entries_on_payment << cheque_entry
        particular.current_user_id = current_user_id
        particular.save!
      end
      bank_particular.cheque_entries << cheque_entries
    end
  end
end
