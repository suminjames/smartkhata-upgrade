class Mandala::AccountBalance < ActiveRecord::Base
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