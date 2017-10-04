require 'rails_helper'

RSpec.describe MenuPermissionModule, type: :helper do
  let(:dummy_class) { Class.new { extend MenuPermissionModule } }

  describe '.get_blocked_path_list' do
    let(:user_access_role){create(:user_access_role)}
    it 'should return blocked path list' do
      allow(MenuItem).to receive(:black_listed_paths_for_user).and_return('dummy path')
      expect(dummy_class.get_blocked_path_list(user_access_role.id)).to eq('dummy path')
    end
  end

  # describe '.is_blocked_path' do
  #   it 'should return true' do
  #     blocked_path_list = allow(dummy_class).to receive(:get_blocked_path_list).and_return('dummy path')
  #     expect(dummy_class.is_blocked_path('dummy path', blocked_path_list)).to eq(true)
  #   end
  # end
end