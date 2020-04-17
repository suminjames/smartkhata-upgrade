# == Schema Information
#
# Table name: account_balance
#
#  id                 :integer          not null, primary key
#  ac_code            :string
#  sub_code           :string
#  balance_amount     :string
#  balance_date       :string
#  fiscal_year        :string
#  balance_type       :string
#  nrs_balance_amount :string
#  closed_by          :string
#  closed_date        :string
#

class Mandala::AccountBalance < ApplicationRecord
  self.table_name = "account_balance"
  include FiscalYearModule

  def chart_of_account
    chart_of_accounts = Mandala::ChartOfAccount.where(ac_code: ac_code)
    if chart_of_accounts.size != 1
      raise NotImplementedError
    end
    chart_of_accounts.last
  end

  def fy_code
    get_fy_code_from_fiscal_year(fiscal_year)
  end
end
