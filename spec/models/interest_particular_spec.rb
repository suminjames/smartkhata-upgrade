# == Schema Information
#
# Table name: interest_particulars
#
#  id            :integer          not null, primary key
#  amount        :string
#  rate          :integer
#  date          :date
#  interest_type :integer
#  ledger_id     :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'rails_helper'

RSpec.describe InterestParticular, type: :model do
  let(:subject){ InterestParticular.new(amount: amount, date: date, rate: rate, interest_type: interest_type, ledger_id: ledger_id) }

  let(:amount) { 100.0 }
  let(:date){ Date.today }
  let(:rate){ 10 }
  let(:interest_type){ 'dr' }
  let(:ledger_id){ 1 }

  let(:ledger){ create(:ledger, client_account: client_account) }
  let(:particular){ create(:particular, fy_code: 7778, transaction_type: 0, amount: 500, value_date: Date.today - 15.days) }
  let(:interest_rate){ create(:interest_rate) }
  let(:client_account){ create(:client_account, user: user) }
  let!(:interest_rate){ create(:interest_rate) }
  let(:user){ create(:user) }

  describe "associations" do
    it { should belong_to(:ledger) }
  end

  it { should define_enum_for(:interest_type).with([:dr, :cr]) }
  
  describe ".calculate_interest" do
    let(:particular_net_calculator) { instance_double(ParticularNetCalculator) }

    before do
      allow(particular_net_calculator).to receive(:call).and_return(500.00)
      ledger.particulars << particular
      interest_rate
    end
  
    it "creates the record with the interest for the client account" do
      InterestParticular.calculate_interest(date)
      expect(InterestParticular.last.amount).to eq("50.0")
    end
  end
end
