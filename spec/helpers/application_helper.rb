require 'rails_helper'
RSpec.describe ApplicationHelper, type: :helper do
  describe  '#equal_amounts?' do
    it 'returns true if it is inside margin' do
      correct_combinations = [[1, 1.01],[1, 0.99], [-1, -1.01],[-1, -0.99],[0, 0], [0, 0.005]]
      correct_combinations.each do |amounts|
        expect(helper.equal_amounts?(amounts[0], amounts[1])).to be true
      end
    end

    it 'returns false if it is not inside margin' do
      correct_combinations = [[1, 1.02],[1, 0.98], [-1, -1.02],[-1, -0.98],[0, 0.02], [0, -0.98]]
      correct_combinations.each do |amounts|
        expect(helper.equal_amounts?(amounts[0], amounts[1])).to be false
      end
    end
  end
end
