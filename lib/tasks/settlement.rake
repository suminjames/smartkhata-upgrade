namespace :settlement do

  task :validate_tenant, [:tenant] => :environment  do |task, args|
    abort 'Please pass a tenant name' unless args.tenant.present?
    tenant = args.tenant
    Apartment::Tenant.switch!(args.tenant)
  end

  desc "patch the settlements"
  task :patch_particulars, [:tenant, :branch_id, :fy_code] => 'mandala:validate_tenant' do |task, args|
    # for those without particular associations
    branch_id = args.branch_id
    fy_code = args.fy_code
    count = 0
    ActiveRecord::Base.transaction do
      Settlement.includes(:particular_settlement_associations).by_branch_fy_code(branch_id, fy_code).where(particular_settlement_associations: {settlement_id: nil}).find_each do |settlement|
        voucher = settlement.voucher

        if !(voucher.payment_bank? || voucher.journal? || voucher.receipt_bank? || voucher.receipt_cash? || voucher.payment_cash?)
          raise   NotImplementedError
        end

        voucher.particulars.select{|x| x.dr?}.each do |p|
          if voucher.payment_bank? || voucher.journal? || voucher.payment_cash?
            if (p.amount - settlement.amount ).abs < 0.01
              p.debit_settlements << settlement
            end
          else
            p.debit_settlements << settlement
          end
        end

        voucher.particulars.select{|x| x.cr?}.each do |p|
          if voucher.receipt_bank? || voucher.receipt_cash?
            if (p.amount - settlement.amount ).abs < 0.01
              p.credit_settlements << settlement
            end
          else
            p.credit_settlements << settlement
          end

        end
        count += 1
        puts "settlement: #{settlement.name}"
        puts "total processed : #{count}"
      end
    end
  end
end