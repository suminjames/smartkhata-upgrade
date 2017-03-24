namespace :demo do
  task :populate_client_accounts, [:tenant] => 'smartkhata:validate_tenant' do |task, args|
    nepse_codes = %w(SK1 SK2 SK3 SK4 SK5 SK6)
    array_num_to_words = %w(ONE TWO THREE FOUR FIVE SIX)


    Apartment::Tenant.switch!(args.tenant)
    UserSession.user = User.first

    nepse_codes.each_with_index do |code, index|
      # make sure to change it on the files associated
      client_type = :individual
      client_name = "USER #{array_num_to_words[index]}"
      branch_id = Branch.first.id

      if code == 'SK2'
        client_type = :corporate
        client_name = "#{client_name} COMPANY LTD."
        email = "mesubas@gmail.com"
      end

      boid ||= nil
      email ||= nil

      branch = Branch.find_or_create_by!(code: "CHI", address: "Chitwan")
      if code == 'SK4'
        branch_id = branch.id
        boid = '101010100001234'
      end

      client = ClientAccount.find_or_create_by!(nepse_code: code) do |client|
        client.name = client_name.titleize
        client.skip_validation_for_system = true
        client.client_type = client_type
        client.branch_id = branch_id
        client.boid = boid
        client.email = email
      end

    end

    Apartment::Tenant.switch!('public')
  end



end