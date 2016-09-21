class SettlementDecorator < ApplicationDecorator
  decorates :settlement
  delegate_all

  # Define presentation-specific methods here. Helpers are accessed through
  # `helpers` (aka `h`). You can override attributes, for example:
  #
  #   def created_at
  #     helpers.content_tag :span, class: 'time' do
  #       object.created_at.strftime("%a %m/%d/%y")
  #     end
  #   end

  # Stringification of cheque numbers and corresponding bank names is done in the same method
  #  to avoid speed degradation, which would come with separate calls for stringification of cheque_numbers
  #  and bank_names.
  def formatted_cheque_numbers_and_bank_names(strip: true)
    cheque_numbers = []
    bank_names = []
    object.cheque_entries.each do |cheque_entry|
      cheque_numbers <<  cheque_entry.cheque_number
      bank_name = cheque_entry.receipt? ? cheque_entry.additional_bank.name : cheque_entry.bank_account.bank_name
      # strip the bank name
      cutoff_length = strip ? 20 : 100
      bank_name = bank_name.length > cutoff_length ? "#{bank_name[0..cutoff_length-1]}..." : bank_name
      bank_names << bank_name
    end
    return {
        :cheque_numbers => cheque_numbers.join("<br>"),
        :bank_names => bank_names.join("<br>")
    }
  end

end
