module BankPaymentLettersHelper
  def client_bank_details(client_account)
    if client_account.has_sufficient_bank_account_info?
      "#{client_account.bank_name}<br>#{client_account.bank_account}<br>#{client_account.bank_address}".html_safe
    else
      "<a class='no-hover warning-text' data-toggle='tooltip' title='Client does not have a bank account.'>N/A</a>".html_safe
    end
  end
end
