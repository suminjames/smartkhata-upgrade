# == Schema Information
#
# Table name: broker_profiles
#
#  id            :integer          not null, primary key
#  broker_name   :string
#  broker_number :string
#  address       :string
#  dp_code       :integer
#  phone_number  :string
#  fax_number    :string
#  email         :string
#  pan_number    :string
#  profile_type  :integer
#  locale        :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class MasterSetup::BrokerProfile < BrokerProfile
  default_scope { is_self_broker }
end
