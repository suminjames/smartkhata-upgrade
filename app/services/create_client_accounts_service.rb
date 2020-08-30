class CreateClientAccountsService
  include ApplicationHelper
  
  attr_reader :record_size
  
  def initialize(record_size)
    @record_size = record_size
  end
  
  def call
    client_types = %w(individual corporate)
    client_boid = %w(101010100001234 101010100001235 101010100001236 101010100001237  101010100001238 10101010000123 101010100001234  101010100001240 101010100001241 101010100001242)
    branch_id= User.first.branch_id

    record_size.times do
      client_account = ClientAccount.create(
        name: Faker::Name.name,
        nepse_code: Faker::Alphanumeric.unique.alpha(number: 4),
        client_type: client_types.sample,
        branch_id: branch_id,
        boid: client_boid.sample,
        email: Faker::Internet.email,
        creator_id: User.first&.id,
        updater_id: User.first&.id)

      voucher_type = Voucher.voucher_types.keys.sample
      voucher_records = []

      rand(1..5).times do
        voucher_records << Voucher.create(
          voucher_type: voucher_type,
          creator_id: User.first&.id,
          updater_id: User.first&.id,
          branch_id: branch_id,
          voucher_status: 1)
      end

      description = "Share Purchase"
      acting_user = User.first
      date = Date.today
      client_ledger = client_account.ledger

      rand(1..5).times do |index|

        puts "============"
        puts "#{index}"
        puts "============="

        random_amount = rand.to_s[2..5].to_i
        client_branch_id = branch_id
        value_date = Date.today + rand(30)
        random_voucher = voucher_records.sample
        debit = [true, false].sample

        process_accounts(client_ledger, random_voucher, debit, random_amount, description, client_branch_id, date, acting_user, value_date)
      end
    end
  end
end



