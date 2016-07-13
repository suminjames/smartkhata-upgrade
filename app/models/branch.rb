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
  validates_presence_of :code, :address
  validates :code, uniqueness: {case_sensitive: false}

  def code=(val)
    write_attribute :code, val.upcase
  end
end
