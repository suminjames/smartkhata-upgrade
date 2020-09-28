# == Schema Information
#
# Table name: chart_of_account
#
#  id              :integer          not null, primary key
#  ac_code         :string
#  sub_code        :string
#  ac_name         :string
#  account_type    :string
#  currency_code   :string
#  control_account :string
#  sub_ledger      :string
#  reporting_group :string
#  mgr_ac_code     :string
#  mgr_sub_code    :string
#  fiscal_year     :string
#  ledger_id       :integer
#  group_id        :integer
#

class Mandala::ChartOfAccount < ActiveRecord::Base
  self.table_name = "chart_of_account"
  belongs_to :ledger, class_name: '::Ledger'

  @@account_group_map = {
      '10301' => 'Clients'
  }

  @@client_mgr_ac_code = '10301'

  scope :non_ledger,  -> { where.not(account_type: 'T')}
  scope :primary, -> {non_ledger.where(mgr_ac_code: '') }

  def child_groups
    self.class.non_ledger.where(mgr_ac_code: self.ac_code)
  end

  def find_or_create_ledger
    ledger = nil
    if self.ledger_id.present?
      ledger =  self.ledger
    else
      # client ledgers
      if mgr_ac_code == @@client_mgr_ac_code
        client_registration = self.client_registration
        if client_registration.present?
          client = client_registration.find_or_create_smartkhata_client_account
          ledger = client.find_or_create_ledger
        end
      end

      begin
        ledger ||= ::Ledger.create!(name: self.ac_name, group_id: self.smartkhata_group_id)
        self.ledger_id = ledger.id
        self.save!
      rescue
        p 'rescued'
      end

    end
    ledger
  end

  def smartkhata_group_id
    return self.group_id if self.group_id.present?
    parent_account.smartkhata_group_id if parent_account.present?
  end

  def parent_account
    Mandala::ChartOfAccount.where(ac_code: self.mgr_ac_code).first
  end

  def client_registration
    Mandala::CustomerRegistration.where(ac_code: self.ac_code).first
  end

  def account_balances
    Mandala::AccountBalance.where(ac_code: self.ac_code)
  end
  # def show_tree
  #   line = ""
  #   self.child_groups.each do |x|
  #
  #     if x.child_groups.size > 0
  #       line += x.show_tree
  #     else
  #       "## #{x.ac_name} /n"
  #     end
  #   end
  #   puts line
  # end
end
