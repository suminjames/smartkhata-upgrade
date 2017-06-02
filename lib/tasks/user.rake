namespace :user do

  desc "Sync users from csv"
  task :sync_with_csv_data,[:tenant, :mimic] => 'smartkhata:validate_tenant' do |task, args|

    mimic = args[:mimic] == 'true' ? true : false

    dir = "#{Rails.root}/test_files/"
    users_csv_file =  dir + 'users.csv'

    csv_text = File.read(users_csv_file)
    csv = CSV.parse(csv_text, :headers => true)
    users_from_csv_arr = []

    csv.each do |row|
      users_from_csv_arr << row.to_hash
    end

    relevant_attributes = [
        "email",
        # "encrypted_password",
        # "reset_password_token",
        # "reset_password_sent_at",
        # "remember_created_at",
        # "sign_in_count",
        "name",
        # "confirmation_token",
        # "confirmed_at",
        # "confirmation_sent_at",
        # "unconfirmed_email",
        "role",
        # "invitation_token",
        # "invitation_created_at",
        # "invitation_sent_at",
        # "invitation_accepted_at",
        # "invitation_limit",
        # "invited_by_id",
        # "invited_by_type",
        # "invitations_count",
        "branch_id",
        # "user_access_role_id",
        "username",
        "pass_changed",
        "temp_password",
    ]

    integer_attrs = [
        "role",
        "sign_in_count",
        "invitation_limit",
        "invited_by_id",
        "invitations_count",
        "branch_id"

    ]
    date_time_attrs = [
        "created_at",
        "reset_password_sent_at",
        "remember_created_at",
        "confirmed_at",
        "confirmation_sent_at",
        "invitation_created_at",
        "invitation_sent_at",
        "invitation_accepted_at",
    ]

    ActiveRecord::Base.transaction do
      users_from_csv_arr.each do |user_from_csv|
        User.find_or_create_by!(email: user_from_csv["email"]) do |user|
          pass = user_from_csv["email"].split("@")[0]
          user.password = user.password_confirmation = pass
          # update relevant attributes
          relevant_attributes.each do |attr|
            if user_from_csv[attr].present?
              if date_time_attrs.include?(attr)
                user_from_csv[attr] =  DateTime.parse(user_from_csv[attr])
              end
              if integer_attrs.include?(attr)
                user_from_csv[attr] =  user_from_csv[attr].to_i
              end
              user.send("#{attr}=", user_from_csv[attr])
            end
          end
        end
      end
    end

  end
end
