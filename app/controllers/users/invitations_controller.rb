class Users::InvitationsController < Devise::InvitationsController
  include ApplicationHelper
  def create
    authorize self
    require 'securerandom'


    url = request.referer || client_accounts_path

    ids_with_email_initial = params[:ids_for_invite].map(&:to_i) if params[:ids_for_invite].present?
    ids_without_email = params[:ids_for_create].map(&:to_i) if params[:ids_for_create].present?
    ids_without_email ||= []
    ids_with_email_initial ||= []

    # remove redundant ids if selected
    # give priority to user ids rather than email
    ids_with_email = ids_with_email_initial - ids_without_email
    ids_with_email ||= []

    if ids_with_email.blank? and ids_without_email.blank?
      redirect_to url, :alert => "Select atleast one client" and return
    end

    ids_with_email.each do |id|
      account = ClientAccount.find_by(id: id)
      accounts = ClientAccount.where(email: account.email)
      # update the accounts to invited.
      ActiveRecord::Base.transaction do
        user = User.invite!(
            :email => account.email,
            :role => :client,
            :branch_id => @selected_branch_id
        ) if valid_email?(account.email)

        accounts.each do |a|
          a.skip_validation_for_system = true
          a.user_id = user.id
          a.update(invited: true)
        end
      end
    end

    ids_without_email.each do |id|
      temp_password = SecureRandom.hex(3)
      account = ClientAccount.find_by(id: id)
      account.skip_validation_for_system = true

      ActiveRecord::Base.transaction do
        new_user = User.create!(
            {
                :username => account.nepse_code,
                :role => :client,
                :branch_id => @selected_branch_id,
                :password => temp_password,
                :password_confirmation => temp_password,
                confirmed_at: Time.now,
                temp_password: temp_password,
                email: nil
            }
        )

        account.user_id = new_user.id
        account.save!
      end
    end

    notice = "Action completed successfully"
    redirect_to url, :notice => notice
  end

  private
  def valid_email?(email)
    # VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    true if email.present? && (email =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i)
  end
end