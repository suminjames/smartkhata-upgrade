desc "Delete a voucher"
namespace :voucher do
  task :delete, [:tenant, :id] => :environment do |task,args|
    def recalculate_dailies(daily_balances)
      opening_balance = 0
      closing_balance = 0
      daily_balances.each do |daily|
        if opening_balance == 0
          opening_balance = daily.opening_balance
          closing_balance = daily.closing_balance
        else
          opening_balance = closing_balance
          daily.opening_balance = opening_balance
          closing_balance = opening_balance + daily.dr_amount - daily.cr_amount
          daily.closing_balance = closing_balance
          daily.save!
        end
      end
    end

    if args.tenant.present? && args.id.present?
      Apartment::Tenant.switch!(args.tenant)
      UserSession.user = User.first

      voucher = Voucher.find(args.id)
      current_fy_code = voucher.fy_code


      UserSession.selected_branch_id = voucher.branch_id
      UserSession.selected_fy_code= current_fy_code


      ActiveRecord::Base.transaction do
        voucher.particulars.each do |p|
          ledger = p.ledger
          branch_id = p.branch_id

          puts "processing the particular for #{ledger.name}"
          amount = p.cr? ? p.amount : (p.amount * -1)

          ledger_blnc_org = LedgerBalance.by_fy_code_org(current_fy_code).find_by(ledger_id: ledger.id)
          ledger_blnc_cost_center =  LedgerBalance.by_branch_fy_code(branch_id,current_fy_code).find_by(ledger_id: ledger.id)
          ledger_blnc_cost_center.closing_balance += amount
          ledger_blnc_org.closing_balance += amount

          if p.cr?
            ledger_blnc_cost_center.cr_amount += amount
            ledger_blnc_org.cr_amount += amount
          else
            ledger_blnc_cost_center.dr_amount += amount
            ledger_blnc_org.dr_amount += amount
          end

          ledger_blnc_org.save!
          ledger_blnc_cost_center.save!

          p.delete


          all_cost_center_dailies = ledger.ledger_dailies.where(branch_id: nil).order('date ASC')
          branch_cost_center_dailies = ledger.ledger_dailies.where(branch_id: 1).order('date ASC')

          recalculate_dailies(all_cost_center_dailies)
          recalculate_dailies(branch_cost_center_dailies)
        end

        voucher.delete

        puts "Task completed "
      end


      Apartment::Tenant.switch!('public')
    else
      puts 'Please pass a tenant and id to the task'
    end
  end
end