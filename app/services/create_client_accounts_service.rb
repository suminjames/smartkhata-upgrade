class CreateClientAccountsService
  include ApplicationHelper
  
  attr_reader :record_size, :acting_user, :branch_id
  
  def initialize(record_size, acting_user = nil, branch_id = nil)
    @record_size = record_size
    @acting_user = acting_user || User.first
    @branch_id = branch_id || @acting_user.branch_id
  end
  
  def call
    bulk_client_accounts
    bulk_client_ledgers
    bulk_vouchers
    bulk_particulars
  end

  def bulk_client_accounts
    client_types = %w(individual corporate)
    client_boid = %w(101010100001234 101010100001235 101010100001236 101010100001237  101010100001238 10101010000123 101010100001234  101010100001240 101010100001241 101010100001242)

    client_accounts = []

    record_size.times do
      client_accounts << ClientAccount.new(
        name: Faker::Name.name,
        nepse_code: Faker::Alphanumeric.unique.alpha(number: 4),
        client_type: client_types.sample,
        branch_id: branch_id,
        boid: client_boid.sample,
        email: Faker::Internet.email,
        creator_id: acting_user.id,
        updater_id: acting_user.id)
    end

    ClientAccount.import client_accounts
  end

  def bulk_client_ledgers
    # activerecord import doesn't support callbacks by default so need to create ledgers manually for every clientaccount
    client_group = Group.find_or_create_by!(name: "Clients")

    client_ledgers = []

    ClientAccount.find_each do |ca|
      client_ledgers << Ledger.new(
        name: ca.name,
        client_account_id: ca.id,
        group_id: client_group.id
      )
    end

    Ledger.import client_ledgers
  end

  def bulk_vouchers
    voucher_type = Voucher.voucher_types.keys.sample

    vouchers_collection = []

    rand(10..50).times do
      vouchers_collection << Voucher.new(
        voucher_type: voucher_type,
        creator_id: acting_user.id,
        updater_id: acting_user.id,
        branch_id: branch_id,
        voucher_status: 1)
    end

    Voucher.import vouchers_collection
  end

  def bulk_particulars
    ledger_records = Ledger.find_all_client_ledgers
    voucher_records = Voucher.all
    description = "Share Purchase"

    particulars_collection = []

    ledger_records.find_each do |ledger|
      rand(1..5).times do |index|

        puts "============"
        puts "#{index}"
        puts "============="

        random_amount = rand.to_s[2..5].to_i
        value_date = Date.today + rand(30)
        accounting_date = Time.now
        random_voucher = voucher_records.sample
        transaction_type = Particular.transaction_types.keys.sample

        particulars_collection << Particular.new(
          transaction_type: transaction_type,
          ledger_id: ledger.id,
          name: description,
          voucher_id: random_voucher.id,
          amount: random_amount,
          transaction_date: accounting_date,
          branch_id: branch_id,
          fy_code: get_fy_code(accounting_date),
          creator_id: acting_user.id,
          updater_id: acting_user.id,
          current_user_id: acting_user.id,
          value_date: value_date)
      end
    end

    Particular.import particulars_collection
  end
end

