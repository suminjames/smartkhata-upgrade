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
#  temp_password          :string
#

class User < ApplicationRecord
  include Auditable

  include MenuPermissionModule

  enum role: { user: 0, client: 1, agent: 2, employee: 3, admin: 4, sys_admin: 5 }
  enum office_roles: { manager: 0 }

  after_initialize :set_default_role, if: :new_record?
  attr_accessor :login, :name_for_user, :current_branch_id, :current_fy_code

  has_many :client_accounts
  has_one :employee_account

  belongs_to :branch

  has_many :menu_permissions, through: :user_access_role
  has_many :branch_permissions
  belongs_to :user_access_role, required: false

  ########################################
  # Validation
  validates :username, uniqueness: { case_sensitive: false, allow_blank: true }
  validates :username, format: { with: /^[a-zA-Z0-9_\.]*$/, multiline: true }
  validates :username, presence: { if: ->(o) { o.email.blank? } }
  validates :email, presence: { if: ->(o) { o.username.blank? } }
  validates :email, uniqueness: { allow_blank: true }
  validates :email, format: { with: /\A[^@]+@[^@]+\z/, allow_blank: true }
  validates :password, length: { in: 4..20 }, on: :create
  validates :password, length: { in: 4..20 }, on: :update, allow_blank: true
  validates :password, confirmation: { if: :password_required? }

  ########################################
  # Callbacks
  before_save :check_password_changed

  # accepts_nested_attributes_for :menu_permissions

  # accepts_nested_attributes_for :branch_permissions
  def set_default_role
    self.role ||= :user
  end

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :confirmable, :registerable,
         :recoverable, :rememberable, :trackable, authentication_keys: [:login]

  attr_accessor :current_url_link

  # def self.client_logged_in?
  #   UserSession.user.client?
  # end

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
      where(conditions.to_hash).where(["lower(username) = :value OR lower(email) = :value", { value: login.downcase.strip }]).first
    elsif conditions.key?(:username) || conditions.key?(:email)
      where(conditions.to_hash).first
    end
  end

  # Checks whether a password is needed or not. For validations only.
  # Passwords are always required if it's a new record, or if the password
  # or confirmation are being set somewhere.
  def password_required?
    !persisted? || !password.nil? || !password_confirmation.nil?
  end

  # check if the password is changed and change the temp password to nil
  # also make sure it is not the case where it is created or reset by the admin
  # in which case temp password will also have changed
  def check_password_changed
    self.temp_password = nil if changed.include?('encrypted_password') && !changed.include?('temp_password')
  end

  def is_official?
    self.admin? || self.employee?
  end

  def name_for_user
    self.email || self.username
  end

  def can_read_write?
    self.current_branch_id != 0 && (self.admin? || (self.employee? && self.user_access_role.try(:read_and_write?)))
  end

  # get the branches that are available for the user
  # for admin and client all the branch are available
  # for employee only those assigned on the permission
  def available_branches
    @available_branches ||= begin
      _available_branches = []
      if self.admin? || self.client?
        _available_branches = Branch.all
      else
        branch_ids = self.branch_permissions.pluck(:branch_id)
        _available_branches = Branch.where(id: branch_ids)
      end
      _available_branches
    end
  end

  def available_branch_ids
    @available_branch_ids ||= begin
      branch_ids = available_branches.pluck(:id).uniq
      branch_ids << 0 if branch_ids.length == Branch.count
      branch_ids
    end
  end

  def can_access_branch?
    available_branch_ids.include?(current_url_link.split('/')[2].to_i)
  rescue
    false
  end
end
