FactoryBot.define do
	factory :group do
		# name "Assets"
		sequence(:name) {|n| "Group-#{n}"}
		current_user_id { User.first&.id || create(:user).id }
	end
end
