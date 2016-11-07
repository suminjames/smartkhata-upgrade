class Mandala::ChartOfAccount < ActiveRecord::Base
  self.table_name = "chart_of_account"
  belongs_to :ledger, class_name: '::Ledger'


  def find_or_create_ledger
    ledger = nil
    if self.ledger_id.present?
      ledger =  self.ledger
    else
      begin
      ledger = ::Ledger.create!(name: self.ac_name)
      self.ledger_id = ledger.id
      self.save!
      rescue
        debugger
      end

    end
    ledger
  end

  def client_account
    Mandala::CustomerRegistration.where(ac_code: self.ac_code).first
  end
end