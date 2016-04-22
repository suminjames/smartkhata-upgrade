# author: Subas Poudel
# email: poudel.subas089@gmail.com
# Used to access the authenticated user in the models

class UserSession
  class << self
    attr_reader :user
    delegate :id, :email, :branch_id, to: :user
    # Stores the current_user for devise using the application_controller
    def user=(usr)
      raise 'You must pass a User class' unless usr.is_a?(User)
      @user = usr
    end

    def user_id
      user.id
    end

    def branch_id
      user.branch_id
    end

    def destroy
      @user = nil
    end
  end

end
