# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default("")
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  name                   :string
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string
#  role                   :integer
#  invitation_token       :string
#  invitation_created_at  :datetime
#  invitation_sent_at     :datetime
#  invitation_accepted_at :datetime
#  invitation_limit       :integer
#  invited_by_id          :integer
#  invited_by_type        :string
#  invitations_count      :integer          default(0)
#  branch_id              :integer
#  user_access_role_id    :integer
#  username               :string
#  pass_changed           :boolean          default(FALSE)
#

class User < ActiveRecord::Base
  include Auditable

  include MenuPermissionModule

  enum role: [:user, :client, :agent, :employee, :admin, :sys_admin]
  enum office_roles: [:manager]

  after_initialize :set_default_role, :if => :new_record?
  attr_accessor :login

  has_many :client_accounts
  has_one :employee_account

  belongs_to :branch

  has_many :menu_permissions, through: :user_access_role
  has_many :branch_permissions
  belongs_to :user_access_role


  ########################################
  # Validation
  validates_uniqueness_of :username, case_sensitive: false, allow_blank: true
  validates_format_of :username, with: /^[a-zA-Z0-9_\.]*$/, :multiline => true
  validates_presence_of   :username, :if => lambda { |o| o.email.blank? }
  validates_presence_of   :email, :if => lambda { |o| o.username.blank? }
  validates_uniqueness_of :email, allow_blank: true
  validates_format_of     :email, with: /\A[^@]+@[^@]+\z/, allow_blank: true
  validates :password, length: { in: 4..20 }, on: :create
  validates :password, length: { in: 4..20 }, on: :update, allow_blank: true
  validates_confirmation_of :password, if: :password_required?

  # accepts_nested_attributes_for :menu_permissions

  # accepts_nested_attributes_for :branch_permissions
  def set_default_role
    self.role ||= :user
  end

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :confirmable,
         :recoverable, :rememberable, :trackable, :authentication_keys => [:login]

  attr_accessor :current_url_link

  def self.client_logged_in?
    UserSession.user.client?
  end

  #
  # A user has_many client_accounts.
  # This method checks if the user object is associated with the client_account_id.
  #
  def belongs_to_client_account(client_account_id)
    self.client_accounts.pluck(:id).include? client_account_id
  end

  def blocked_path_list
    get_blocked_path_list(self.user_access_role_id)
  end

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions.to_hash).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase.strip }]).first
    elsif conditions.has_key?(:username) || conditions.has_key?(:email)
      where(conditions.to_hash).first
    end
  end

  # Checks whether a password is needed or not. For validations only.
  # Passwords are always required if it's a new record, or if the password
  # or confirmation are being set somewhere.
  def password_required?
    !persisted? || !password.nil? || !password_confirmation.nil?
  end
end
