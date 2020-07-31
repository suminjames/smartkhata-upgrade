# == Schema Information
#
# Table name: interest_rates
#
#  id            :integer          not null, primary key
#  start_date    :date
#  end_date      :date
#  interest_type :integer
#  rate          :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'rails_helper'

RSpec.describe InterestRate, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
