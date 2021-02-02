namespace :demo do
  task :populate_client_accounts, [:tenant] => 'smartkhata:validate_tenant' do |task, args|
    nepse_codes = %w(SK1 SK2 SK3 SK4 SK5 SK6)
    array_num_to_words = %w(ONE TWO THREE FOUR FIVE SIX)


    Apartment::Tenant.switch!(args.tenant)

    @admin_users = [
      {:email => 'demo@danfeinfotech.com', :password => '12demo09'},
      {:email => 'demo@danfeinfotech.com', :password => '12demo09'}, #for the public
    ]

    count = 0

    branch = Branch.create(code: "KTM", address: "Kathmandu")
    user_access_role = UserAccessRole.create(role_type: 1, role_name: "Role-1")
    admin_user_data = @admin_users[count - 1]
    new_user = User.find_or_create_by!(email: admin_user_data[:email]) do |user|
      user.password = admin_user_data[:password]
      user.password_confirmation = admin_user_data[:password]
      user.branch_id = branch.id
      user.user_access_role_id = user_access_role.id
      user.confirm
      user.admin!
    end

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
      if code == 'SK1' || code == 'SK3'
        branch_id = branch.id
        boid = '101010100001234'
      end

      if code == 'SK3'
        branch_id = branch.id
      end

      ClientAccount.find_or_create_by!(nepse_code: code) do |client|
        client.name = client_name.titleize
        client.skip_validation_for_system = true
        client.client_type = client_type
        client.branch_id = branch_id
        client.boid = boid
        client.email = email
        client.current_user_id = new_user.id
      end
    end

    Apartment::Tenant.switch!('public')
  end
end
