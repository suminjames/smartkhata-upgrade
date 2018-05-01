FactoryBot.define do
	factory :group do
		# name "Assets"
		sequence(:name) {|n| "Group-#{n}"}
	end
end
