require 'rails_helper'

RSpec.describe Ledger, type: :model do
	subject{build(:ledger)}
  	include_context 'session_setup'

  	describe "validations" do
  		it { should validate_presence_of (:name)}
        #custom validation left 

  		# it "should raise error" do
  		# 	expect{create(:ledger, opening_blnc: -1000)}.to raise_error("can't be negative or blank")
  		# end
  	end

  	describe "#options_for_ledger_type" do
  		it "should return options for ledger type" do
  			expect(subject.class.options_for_ledger_type).to eq(["client","internal"])
  		end
  	end

  	describe "#options_for_ledger_select" do
  		subject{create(:ledger)}
  		it "should return options for ledger selection" do
  			subject
  			expect(subject.class.options_for_ledger_select("by_ledger_id" => subject.id)).to eq([subject])
  		end
  	end

  	describe ".format_client_code" do
  		it "should return client code in uppercase" do
  			subject.client_code = "  danphe  "
  			expect(subject.format_client_code).to eq("DANPHE")
  		end
  	end

  	describe ".format_name" do
  		context "when name is present" do
  			
  			context "and is stippable" do
  				it "should reduce space" do
  					subject.name = " danphe"
  					expect(subject.format_name).to eq("danphe")
  				end
  			end

  			context "and has more than one space between words" do
  				it "should reduce all spaces to single space" do
  					subject.name = "danphe     infotech"
  					expect(subject.format_name).to eq("danphe infotech")
  				end
  			end
  		end

  		context "when name is not present" do
  			it "should return same name" do
  				expect(subject.format_name).to eq("Ledger")
  			end
  		end
  	end

  	describe ".name_from_reserved?" do
  		subject{create(:ledger, name: "Purchase Commission")}
  		context "when name is reserved in system" do
  			it "should raise error" do
  				subject
  				new_ledger = build(:ledger, name: "Purchase Commission")
  				expect(new_ledger).not_to be_valid
  				expect(new_ledger.errors[:name]).to include("The name is reserved by system")
  			end
  		end
  	end

  	describe ".update_closing_blnc" do
  		context "when opening balance is not blank" do
  			it "should return closing balance" do
  				subject.opening_blnc = 800
  				subject.opening_balance_type = 1
  				expect(subject.update_closing_blnc).to eq(-800)
  			end
  		end	
  	end

  	describe ".has_editable_balance?" do
  		it "should return true" do
  			expect(subject.has_editable_balance?).to be_truthy
  		end
  	end

  	describe ".update_custom" do
  		it "should return true" do
  			expect(subject.update_custom(name: "efrqf")).to be_truthy 
  		end
  	end

  	describe ".create_custom" do
  		it "should return true" do
  			allow(subject).to receive(:save_custom).and_return(true)
  			expect(subject.create_custom).to be_truthy
  		end
  	end

  	describe ".save_custom" do
  		context "when valid" do
        context "and params is nil" do
        #   incase of create
          it "should create ledger balance for org" do
						ledger = build(:ledger)
            ledger.ledger_balances << build(:ledger_balance, branch_id: 1, opening_balance: "5000")
            ledger.ledger_balances << build(:ledger_balance, branch_id: 2, opening_balance: "5000")
          	expect { ledger.save_custom }.to change {LedgerBalance.unscoped.count }.by(3)
            expect(LedgerBalance.unscoped.where(branch_id: nil, ledger_id: ledger.reload.id).first.closing_balance).to eq(10000)
          end
        end

        context "and params is present" do
          it "should update ledger balance for org" do
						ledger = create(:ledger)
						ledger.ledger_balances << create(:ledger_balance, branch_id: 2, opening_balance: "5000")
            ledger_balance = create(:ledger_balance, branch_id: 1, opening_balance: "5000")
						ledger.ledger_balances << ledger_balance
						ledger.ledger_balances << create(:ledger_balance, branch_id: nil, opening_balance: "10000")

            params = {"ledger_balances_attributes"=>{"0"=>{"opening_balance"=>"6000.0", "opening_balance_type"=>"dr", "branch_id"=>"1", "id"=> ledger_balance.id }}}

						expect { ledger.save_custom(params) }.to change {LedgerBalance.unscoped.count }.by(0)
            # edit on individual balance should update org balance too
            # org balance has branch id nil
						expect(LedgerBalance.unscoped.where(branch_id: nil, ledger_id: ledger.reload.id).first.closing_balance).to eq(11000)
						expect(LedgerBalance.unscoped.where(branch_id: 1, ledger_id: ledger.reload.id).first.closing_balance).to eq(6000)
          end
        end
      end
      context "when invalid" do
				context "and params is nil" do
					it "should add errors" do
						ledger = build(:ledger)
						ledger.ledger_balances << build(:ledger_balance, branch_id: 1, opening_balance: "5000")
						ledger.ledger_balances << build(:ledger_balance, branch_id: 1, opening_balance: "5000")
						expect(ledger.save_custom).not_to be_truthy
					end
        end
      end
  	end

  	describe ".update_custom_old" do
  		it " "
  	end

  	describe ".particulars_with_running_balance" do
  		it " "
  	end

  	describe ".positive_amount" do
  		context "when opening balance is less than 1" do
  			it "should return error message" do
  				subject.opening_blnc = -400
  				expect(subject.positive_amount).to include("can't be negative or blank")
  			end
  		end
  	end

  	describe ".closing_balance" do
      before do
        UserSession.selected_fy_code = 7374
      end
      context "when session branch is head office" do
        context "and ledger has activities" do
					it "should return correct closing balance" do
            UserSession.selected_branch_id = 0
						subject
						create(:ledger_balance, ledger: subject, fy_code: 7374, branch_id: nil, opening_balance: 5000)
            expect(subject.closing_balance).to eq(5000)
          end
          context "and ledger has no activity" do
						it "should return 0 as closing balance" do
							UserSession.selected_branch_id = 0
							subject
							expect(subject.closing_balance).to eq(0)
            end
          end
        end

      end

      context "when session branch is branch office" do
				it "should return closing balance" do
					UserSession.selected_branch_id = 1
					subject
					create(:ledger_balance, ledger: subject, fy_code: 7374, branch_id: 1, opening_balance: 3000)
					expect(subject.closing_balance).to eq(3000)
				end
      end


  	end

  	describe ".opening_balance" do
      context "when ledger has ledger balance" do
				let(:ledger_balance) {build(:ledger_balance, opening_balance: 5000)}
        it "should return opening balance" do
          allow(LedgerBalance).to receive(:by_branch_fy_code).and_return([ledger_balance])
					expect(subject.opening_balance).to eq(5000)
				end
      end

      context "when ledger has no ledger balance" do
				it "should return opening balance" do
					expect(subject.opening_balance).to eq(0)
				end
      end

  	end

  	describe ".dr_amount" do
			context "when ledger has ledger balance" do
				let(:ledger_balance) {build(:ledger_balance, dr_amount: 5000)}
				it "should return dr amount" do
					allow(LedgerBalance).to receive(:by_branch_fy_code).and_return([ledger_balance])
					expect(subject.dr_amount).to eq(5000)
				end
			end

			context "when ledger has no ledger balance" do
				it "should return opening balance" do
					expect(subject.dr_amount).to eq(0)
				end
			end
  	end

  	describe ".cr_amount" do
			context "when ledger has ledger balance" do
				let(:ledger_balance) {build(:ledger_balance, cr_amount: 5000)}
				it "should return cr amount" do
					allow(LedgerBalance).to receive(:by_branch_fy_code).and_return([ledger_balance])
					expect(subject.cr_amount).to eq(5000)
				end
			end

			context "when ledger has no ledger balance" do
				it "should return opening balance" do
					expect(subject.cr_amount).to eq(0)
				end
			end
  	end

  	describe ".descendent_ledgers" do
  		it "should get descendents ledgers" 
  		# code might not be necessary
  	end

end
