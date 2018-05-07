require 'rails_helper'

RSpec.describe MenuItem, type: :model do
	include_context 'session_setup'
  subject{create(:menu_item)}

  describe "validation" do
  	it {should validate_uniqueness_of(:code)}
  end

  describe "#black_listed_paths_for_user" do
    let(:menu_item){create(:menu_item, path: "nuhg")}
    let(:user_access_role){create(:user_access_role)}
  	let(:menu_permission){create(:menu_permission, user_access_role: user_access_role, menu_item_id: subject.id)}
  	it "should return black listed path" do
  		subject
			menu_item
  		subject.menu_permissions << menu_permission
  		expect(MenuItem.black_listed_paths_for_user(user_access_role.id)).to eq(["nuhg"])
  	end
  end
end
