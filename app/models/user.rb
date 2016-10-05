# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
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
#

class User < ActiveRecord::Base
  include Auditable

  include MenuPermissionModule

  enum role: [:user, :client, :agent, :employee, :admin, :sys_admin]
  enum office_roles: [:manager]

  after_initialize :set_default_role, :if => :new_record?
  has_many :client_accounts
  has_one :employee_account

  has_many :menu_permissions
  has_many :branch_permissions
  accepts_nested_attributes_for :menu_permissions
  # accepts_nested_attributes_for :branch_permissions
  def set_default_role
    self.role ||= :user
  end

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  attr_accessor :current_url_link

  def blocked_path_list
    get_blocked_path_list(self.id)
  end
end
