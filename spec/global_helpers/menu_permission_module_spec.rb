require 'rails_helper'

RSpec.describe MenuPermissionModule, type: :helper do
  include_context 'session_setup'
  # let(:dummy_class) { Class.new { extend MenuPermissionModule attr_accessor :current_user} }
  MenuField =
      Class.new do
        include MenuPermissionModule

        attr_accessor :current_user
      end
  let(:dummy_class) { MenuField.new }


  let(:user_access_role){create(:user_access_role)}
  let(:user) {create(:user, user_access_role_id: user_access_role.id, role: 0, username: 'john', email: 'jhn@gmail.com', branch_id: 1)}
  let(:user1) {create(:user, user_access_role_id: user_access_role.id, username: 'ram', email: 'ram@gmail.com', branch_id: 1)}

  describe '.get_blocked_path_list' do
    it 'should return blocked path list' do
      allow(MenuItem).to receive(:black_listed_paths_for_user).and_return(['dummy path'])
      expect(dummy_class.get_blocked_path_list(user_access_role.id)).to eq(['dummy path'])
    end
  end

  describe '.is_blocked_path' do
    context 'when blocked path  includes path' do
      context 'and current user is user' do
        it 'should return true' do
          blocked_path_list = ['dummy path']
          allow(dummy_class).to receive(:current_user).and_return(user)
          expect(dummy_class.is_blocked_path('dummy path', blocked_path_list)).to eq(true)
        end
      end

      context 'and current user is admin' do
        it 'should return false' do
          blocked_path_list = ['dummy path']
          allow(dummy_class).to receive(:current_user).and_return(user1)
          expect(dummy_class.is_blocked_path('dummy path', blocked_path_list)).to eq(false)
        end
      end
    end

    context 'when blocked path doesnot include path' do
      context 'and current user is user' do
        it 'should return false' do
          blocked_path_list = ['path1']
          allow(dummy_class).to receive(:current_user).and_return(user)
          expect(dummy_class.is_blocked_path('path2', blocked_path_list)).to eq(false)
        end
      end
    end
  end

  # describe '.user_has_access_to?' do
  #   it 'should return true' do
  #     allow(dummy_class).to receive(:current_user).and_return(user1)
  #     allow(ApplicationHelper).to receive(:admin_and_above?).and_return(true)
  #     expect(dummy_class.user_has_access_to?('test.com')).to eq(true)
  #   end
  # end
end
