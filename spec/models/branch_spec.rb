require 'rails_helper'

RSpec.describe Branch, type: :model do
  	subject {build(:branch)}
  
  	include_context 'session_setup'

	describe "validations" do
		it {should validate_presence_of (:code)}
		it {should validate_presence_of (:address)}
		it {should validate_uniqueness_of(:code).case_insensitive}
	end

  	describe "#permitted_branches_for_user" do
  		# since session setup creates a branch which is necessary due to app logic
  		# same case with user
  		let(:branch_1) { Branch.first }
  		let(:branch_2) { create(:branch) }
  		let(:user) { User.last }

  		before do
  			branch_1
  			branch_2
  		end


  		context "when admin" do
  			it "should permit all branches" do
  				user.admin!
  				expect(subject.class.permitted_branches_for_user(user).size).to eq(3)
  			end
  		end

  		context "when user is employee" do
  			context "when user has access to all branches"  do
  				it "should return branches plus an all option" do
  					user.employee!
  					expected = [branch_1.id, branch_2.id]
  					allow(BranchPermission).to receive(:where).with({user_id: user.id}).and_return(double(pluck: expected))
  					expect(subject.class.permitted_branches_for_user(user).size).to eq(3)
  				end
  			end
  			context "when user has access to some branches" do
  				before do
  					user.employee!
  					expected = [branch_1.id]
  					allow(BranchPermission).to receive(:where).with({user_id: user.id}).and_return(double(pluck: expected))
  				end

  				it "should return branches without all option" do
  					
  					expect(subject.class.permitted_branches_for_user(user).size).to eq(1)
  				end

  				it "should return the branch that user has permission" do
  					expect(subject.class.permitted_branches_for_user(user).include? branch_1).to be_truthy
  				end

  			end
  		end  	
  	end

  	describe ".code" do
  		it "should store code in uppercase" do
  			subject.code = "danphe"
  			expect(subject.code).to eq('DANPHE')
  		end
  	end
end