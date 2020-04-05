require 'rails_helper'

RSpec.describe Voucher, type: :model do
  include_context 'session_setup'
	subject{create(:voucher)}

  describe ".voucher_code" do
    context "when voucher type is journal" do
      it "returns voucher code as JVR" do
        subject.journal!
        expect(subject.voucher_code).to eq("JVR")
      end
    end

    context "when voucher type is payment" do
      it "returns voucher code as PMT" do
        subject.payment!
        expect(subject.voucher_code).to eq("PMT")
      end
    end

    context "when voucher type is receipt" do
      it "returns voucher code as RCV" do
        subject.receipt!
        expect(subject.voucher_code).to eq("RCV")
      end
    end

    context "when voucher type is contra" do
      it "returns voucher code as CVR" do
        subject.contra!
        expect(subject.voucher_code).to eq("CVR")
      end
    end

    context "when voucher type is payment_cash" do
      it "returns voucher code as PVR" do
        subject.payment_cash!
        expect(subject.voucher_code).to eq("PVR")
      end
    end


    context "when voucher type is receipt_cash" do
      it "returns voucher code as RCP" do
        subject.receipt_cash!
        expect(subject.voucher_code).to eq("RCP")
      end
    end

    context "when voucher type is payment_bank" do
      it "returns voucher code as PVB" do
        subject.payment_bank!
        expect(subject.voucher_code).to eq("PVB")
      end
    end

    context "when voucher type is receipt_bank" do
      it "returns voucher code as RCB" do
        subject.receipt_bank!
        expect(subject.voucher_code).to eq("RCB")
      end
    end

    context "when voucher type is receipt_bank_deposit" do
      it "returns voucher code as CDB" do
        subject.receipt_bank_deposit!
        expect(subject.voucher_code).to eq("CDB")
      end
    end
  end

  describe ".is_payment_receipt?" do
    context "when voucher type is payment" do
      it "returns true" do
        subject.payment!
        expect(subject.is_payment_receipt?).to be_truthy
      end
    end

    context "when voucher type is receipt" do
      it "returns true" do
        subject.receipt!
        expect(subject.is_payment_receipt?).to be_truthy
      end
    end

    context "when voucher type is payment cash" do
      it "returns true" do
        subject.payment_cash!
        expect(subject.is_payment_receipt?).to be_truthy
      end
    end

    context "when voucher type is receipt cash" do
      it "returns true" do
        subject.receipt_cash!
        expect(subject.is_payment_receipt?).to be_truthy
      end
    end

    context "when voucher type is receipt bank" do
      it "returns true" do
        subject.receipt_bank!
        expect(subject.is_payment_receipt?).to be_truthy
      end
    end

    context "when voucher type is payment bank" do
      it "returns true" do
        subject.payment_bank!
        expect(subject.is_payment_receipt?).to be_truthy
      end
    end

    context "when voucher type is  receipt bank deposit" do
      it "returns true" do
        subject.receipt_bank_deposit!
        expect(subject.is_payment_receipt?).to be_truthy
      end
    end
  end

  describe ".is_payment?" do
    context "when voucher type is payment" do
      it "returns true" do
        subject.payment!
        expect(subject.is_payment?).to be_truthy
      end
    end

    context "when voucher type is payment cash" do
      it "returns true" do
        subject.payment_cash!
        expect(subject.is_payment?).to be_truthy
      end
    end

    context "when voucher type is payment bank" do
      it "returns true" do
        subject.payment_bank!
        expect(subject.is_payment?).to be_truthy
      end
    end
  end

  describe ".is_receipt?" do
    context "when voucher type is receipt" do
      it "returns true" do
        subject.receipt!
        expect(subject.is_receipt?).to be_truthy
      end
    end

    context "when voucher type is receipt cash" do
      it "returns true" do
        subject.receipt_cash!
        expect(subject.is_receipt?).to be_truthy
      end
    end

    context "when voucher type is receipt bank" do
      it "returns true" do
        subject.receipt_bank!
        expect(subject.is_receipt?).to be_truthy
      end
    end

    context "when voucher type is receipt bank deposit" do
      it "returns true" do
        subject.receipt_bank_deposit!
        expect(subject.is_receipt?).to be_truthy
      end
    end
  end

  describe ".is_bank_related_receipt?" do
    context "when voucher type is receipt" do
      it "returns true" do
        subject.receipt!
        expect(subject.is_bank_related_receipt?).to be_truthy
      end
    end

    context "when voucher type is receipt bank" do
      it "returns true" do
        subject.receipt_bank!
        expect(subject.is_bank_related_receipt?).to be_truthy
      end
    end

    context "when voucher type is receipt bank deposit" do
      it "returns true" do
        subject.receipt_bank_deposit!
        expect(subject.is_bank_related_receipt?).to be_truthy
      end
    end
  end

  describe ".is_bank_related_payment?" do
    context "when voucher type is payment" do
      it "returns true" do
        subject.payment!
        expect(subject.is_bank_related_payment?).to be_truthy
      end
    end

    context "when voucher type is payment bank" do
      it "returns true" do
        subject.payment_bank!
        expect(subject.is_bank_related_payment?).to be_truthy
      end
    end
  end

  describe ".map_payment_receipt_to_new_types" do
    context "when voucher type is receipt" do
      let!(:particular){create(:particular, voucher_id: subject.id, branch_id: @branch.id)}
      let!(:cheque_entry1){create(:cheque_entry, branch_id: @branch.id)}
      context "and cheque entries count is greater than 0" do
        it "returns voucher type as receipt bank" do
          subject.voucher_type = "receipt"
          subject.branch_id = @branch.id
          particular.cheque_entries << cheque_entry1
          subject.map_payment_receipt_to_new_types
          # expect(subject.cheque_entries.count).to eq(1)
          expect(subject.voucher_type).to eq("receipt_bank")
        end
      end

      context "and cheque entries count is not greater than 0" do
        it "returns voucher type as receipt cash" do
          subject.voucher_type = "receipt"
          subject.branch_id = @branch.id
          subject.map_payment_receipt_to_new_types
          expect(subject.voucher_type).to eq("receipt_cash")
        end
      end
    end

    context "when voucher type is payment" do
      let!(:particular){create(:particular, voucher_id: subject.id, branch_id: @branch.id)}
      let!(:cheque_entry1){create(:cheque_entry, branch_id: @branch.id)}
      context "and cheque entries count is greater than 0" do
        it "returns voucher type as payment bank" do
          subject.voucher_type = "payment"
          subject.branch_id = @branch.id
          particular.cheque_entries << cheque_entry1
          subject.map_payment_receipt_to_new_types
            # expect(subject.cheque_entries.count).to eq(1)
          expect(subject.voucher_type).to eq("payment_bank")
        end
      end

      context "and cheque entries count is not greater than 0" do
        it "returns voucher type as payment cash" do
          subject.voucher_type = "payment"
          subject.branch_id = @branch.id
          subject.map_payment_receipt_to_new_types
          expect(subject.voucher_type).to eq("payment_cash")
        end
      end
    end
  end

  describe ".has_incorrect_fy_code?" do
    context "when incorrect fy code" do
      it "returns true" do
        subject.fy_code = 7374
        allow_any_instance_of(Voucher).to receive(:get_fy_code).and_return(456)
        expect(subject.has_incorrect_fy_code?).to be_truthy
      end
    end

    context "when correct fy code" do
      it "returns false" do
        subject.fy_code = 7374
        allow_any_instance_of(Voucher).to receive(:get_fy_code).and_return(7374)
        expect(subject.has_incorrect_fy_code?).not_to be_truthy
      end
    end
  end

  describe ".process_voucher" do
    context "when date is not present" do
      it "returns today date" do
        subject.date = nil
        subject.send(:process_voucher)
        expect(subject.date).to eq(Time.now.to_date)
      end
    end

    context "when date bs is not present" do
      it "adds ad date to date bs" do
         subject.date = "2017-06-27"
         subject.date_bs = nil
         subject.send(:process_voucher)
        expect(subject.date_bs).to eq("2074-03-13")
      end
    end

    context "when skip number assign is not true" do
      context "and voucher number is present" do
        subject{create(:voucher, voucher_number: 5)}
         it "returns voucher number" do
          subject.send(:process_voucher)
          expect(subject.voucher_number).to eq(5)
        end
      end

      context "and voucher number is not present" do
        context "and last voucher is present" do
          subject{create(:voucher)}
          let!(:voucher1){create(:voucher, fy_code: 7374, voucher_type: 0, voucher_number: 2)}
          it "returns voucher number of last voucher" do
            subject.send(:process_voucher)
            expect(subject.voucher_number).to eq(3)
          end
        end

        context "and last voucher is not present" do
          subject{create(:voucher)}
          it "returns voucher number as 1" do
            subject.send(:process_voucher)
            expect(subject.voucher_number).to eq(1)
          end
        end
      end
    end

    context "when skip number assign is true" do
      it "returns fy code" do
        subject.date = '2016-8-18'
        subject.send(:process_voucher)
        expect(subject.fy_code).to eq(7374)
      end
    end
  end

  describe ".assign_cheque" do
    let!(:particular_dr){create(:particular, voucher_id: subject.id, transaction_type: "dr", branch_id: @branch.id)}
    let!(:particular_cr){create(:particular, voucher_id: subject.id, transaction_type: "cr", branch_id: @branch.id)}
    let!(:cheque_entry){create(:cheque_entry, branch_id: @branch.id)}

    context "when voucher is payment voucher" do
      before do
        subject.branch_id =  @branch.id
        subject.payment_bank!
        cheque_entry.particulars_on_payment << particular_cr

        allow(UserSession).to receive(:tenant).and_return(Tenant.new(full_name: 'Danphe'))
      end

      it "assigns cheque" do
        subject.send(:assign_cheque)
        expect(particular_dr.cheque_entries_on_payment.size).to eq(1)
        expect(particular_cr.cheque_entries_on_payment.size).to eq(1)
      end

      context "and cheque_beneficiary name is not present" do
        it "should assign beneficiary name from first dr particular" do
          cheque_entry.update_attributes(beneficiary_name: nil)
          subject.send(:assign_cheque)
          expect(cheque_entry.reload.beneficiary_name).to eq(particular_dr.ledger.name)
        end

      end

      context "and internal bank payments" do
        it "should assign beneficiary name to both cheques as company" do
          receipt_cheque_entry = create(:receipt_cheque_entry, branch_id: @branch.id)
          receipt_cheque_entry.particulars_on_receipt << particular_dr

          cheque_entry.update_attributes(beneficiary_name: nil)
          receipt_cheque_entry.update_attributes(beneficiary_name: nil)
          # particulars with bank ledger
          particular_dr.has_bank!
          particular_cr.has_bank!


          subject.reload.send(:assign_cheque)

          expect(particular_dr.cheque_entries_on_payment.size).to eq(1)

          expect(cheque_entry.reload.beneficiary_name).to eq('Danphe')
          expect(receipt_cheque_entry.reload.beneficiary_name).to eq('Danphe')

        end
      end
    end

    context "when voucher is receipt voucher" do
      before do
        subject.branch_id =  @branch.id
        subject.receipt_bank!
        cheque_entry.receipt!

        cheque_entry.particulars_on_receipt << particular_dr
        allow(UserSession).to receive(:tenant).and_return(Tenant.new(full_name: 'Danphe'))
      end

      it "assigns cheque" do
        subject.send(:assign_cheque)
        expect(particular_dr.cheque_entries_on_receipt.size).to eq(1)
        expect(particular_cr.cheque_entries_on_receipt.size).to eq(1)
      end

      context "and cheque_beneficiary name is not present" do
        it "should assign beneficiary name from first cr particular" do
          cheque_entry.update_attributes(beneficiary_name: nil)
          subject.send(:assign_cheque)
          expect(cheque_entry.reload.beneficiary_name).to eq(particular_cr.ledger.name)
        end
      end
    end
  end
end
