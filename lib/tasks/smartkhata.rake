namespace :smartkhata do
  # validation for tenant in the rake argument list
  # raises error if not present

  def current_user
    User.admin.first
  end

  def current_user_id
    current_user&.id
  end

  def all_fy_codes
    return [6869, 6970, 7071, 7273, 7374, 7475, 7677]
  end

  def current_fy_code
    include FiscalYearModule
    return FiscalYearModule::get_fy_code
  end


  desc "validate against tenant"
  task :validate_tenant, [:tenant] => :environment  do |task, args|
    tenant = args.tenant
    abort 'Please pass a tenant name' unless tenant.present?
    Apartment::Tenant.switch!(tenant)
  end
end
