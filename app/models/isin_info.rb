# == Schema Information
#
# Table name: public.isin_infos
#
#  id         :integer          not null, primary key
#  company    :string
#  isin       :string
#  sector     :string
#  max        :decimal(10, 4)   default("0")
#  min        :decimal(10, 4)   default("0")
#  last_price :decimal(10, 4)   default("0")
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class IsinInfo < ActiveRecord::Base
	has_many :share_transactions
end
