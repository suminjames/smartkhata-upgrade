require 'rails_helper'

RSpec.describe Group, type: :model do
	
	subject {create(:group)}
	let(:ledger){create(:ledger, group: subject)}
	let(:child_group) { create(:group, name: 'Child', parent: subject)}
  	include_context 'session_setup'

  describe "validations" do
  	it { should validate_uniqueness_of(:name)}
  
  end

  describe ".get_ledger_group" do
  	subject{create(:group)}
  	context "when level is not present" do
  		it "should return ledger and groups" do
  			# since the descendent ledgers method finds the ledgers using sql 
  			# the object ledger wont be the exact object and hence
  			# we need to allow any instance instead
  			allow_any_instance_of(Ledger).to receive(:closing_balance).and_return(878)
  			ledger
  			group_ledger = subject.get_ledger_group 
  			expect(group_ledger[:balance]).to eq(878)			
  			expect(group_ledger[:ledgers]).to eq([])			
  			expect(group_ledger[:child_group]).to eq({})			
  		end
  	end
  	context "when level is greater than 1" do
  		before do
  			allow_any_instance_of(Ledger).to receive(:closing_balance).and_return(800)
  			ledger
	  	end

  		context "and no child group is present" do
  			it "should return ledgers" do
	  			
	  			group_ledger = subject.get_ledger_group(drill_level: 2) 
	  			expect(group_ledger[:balance]).to eq(800)			
	  			expect(group_ledger[:ledgers]).to eq([ledger])			
	  			expect(group_ledger[:child_group]).to eq({})
  			end
  		end

  		context "and child group is present" do
  			

  			it "should return ledger and groups" do
  				ledger
  				child_ledger = create(:ledger, name: 'Child ledger', group: child_group)

	  		
	  			group_ledger = subject.get_ledger_group(drill_level: 2) 
	  			expect(group_ledger[:balance]).to eq(1600)			
	  			expect(group_ledger[:ledgers]).to eq([ledger])			
	  			expect(group_ledger[:child_group]).to eq({"Child"=>{:balance=>800, :ledgers=>[], :child_group=>{}}})
  			end

  			it 'should also return child ledgers' do
  				child_ledger = create(:ledger, name: 'Child ledger', group: child_group)

	  		
	  			group_ledger = subject.get_ledger_group(drill_level: 3) 
	  			expect(group_ledger[:balance]).to eq(1600)			
	  			expect(group_ledger[:ledgers]).to eq([ledger])			
	  			expect(group_ledger[:child_group]).to eq({"Child"=>{:balance=>800, :ledgers=>[child_ledger], :child_group=>{}}})
  			end

  		end
  	end
  end

  describe '.self_and_descedents' do
  	it "should get self and child groups" do
  		subject
  		child_group
  		expect(subject.self_and_descendents).to eq([subject,child_group])
  	end
  end

  describe '.descedents' do
  	it "should get child groups" do
  		subject
  		child_group
  		expect(subject.descendents).to eq([child_group])
  	end
  end

  describe ".descendent_ledgers" do
  	it "should return descendent ledgers" do
  		subject
  		ledger
  		child_group
  		child_ledger = create(:ledger, name: 'Child ledger', group: child_group)
  		expect(subject.descendent_ledgers(7374).to_a).to eq([child_ledger,ledger])	
  	end
  end

  describe '.closing_balance' do
  	it "should return closing balance" do
  		allow_any_instance_of(Ledger).to receive(:closing_balance).and_return(888)
  		# allow(subject).to receive(:descendent_ledgers).and_return([ledger])
  		ledger
  		expect(subject.closing_balance).to eq(888)
  	end	

  end

  describe ".tree_for" do
  	it "should order table name" do
  		expect(subject.class.tree_for(subject)).to eq([subject])
  	end
  end

  describe ".tree_sql_for" do
  	it ""
  	# did not find a proper way to match
  end


end