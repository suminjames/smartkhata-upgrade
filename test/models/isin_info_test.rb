# == Schema Information
#
# Table name: public.isin_infos
#
#  id         :integer          not null, primary key
#  company    :string
#  isin       :string
#  sector     :string
#  max        :decimal(10, 4)   default(0.0)
#  min        :decimal(10, 4)   default(0.0)
#  last_price :decimal(10, 4)   default(0.0)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class IsinInfoTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  def setup
    @isin_info = create(:isin_info)
  end

  test "valid isin" do
    assert @isin_info.valid?
  end

  test "invalid without name" do
    @isin_info.company = nil
    refute @isin_info.valid?
  end

  test "invalid without code" do
    @isin_info.isin = nil
    refute @isin_info.valid?
  end

  test "invalid with same code" do
    new = @isin_info.dup
    new.save
    assert_includes new.errors, :isin
  end

  test "valid with different code" do
    new = @isin_info.dup
    new.isin = 'DAD'
    assert new.valid?
  end
end


