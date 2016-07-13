module BankPaymentLettersHelper
  def client_bank_details(client_account)
    if client_account.bank_name.nil?
    "<a class='no-hover warning-text' data-toggle='tooltip' title='Client does not have a bank account.'>N/A</a>".html_safe
    else
      "#{client_account.bank_name}<br>#{client_account.bank_account}<br>#{client_account.bank_address}".html_safe
    end
  end
end
