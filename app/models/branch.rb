# == Schema Information
#
# Table name: branches
#
#  id         :integer          not null, primary key
#  code       :string
#  address    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#


class Branch < ActiveRecord::Base
end
