class ShareTransactionDecorator < Draper::Decorator
  delegate_all

  # Define presentation-specific methods here. Helpers are accessed through
  # `helpers` (aka `h`). You can override attributes, for example:
  #
  #   def created_at
  #     helpers.content_tag :span, class: 'time' do
  #       object.created_at.strftime("%a %m/%d/%y")
  #     end
  #   end

  def formatted_company_name
    object.isin_info.company.to_s + '(' + object.isin_info.isin.to_s + ')'
  end

  def formatted_share_rate
    h.arabic_number (object.share_rate)
  end

  def formatted_amount
    h.arabic_number(object.share_amount)
  end

  def formatted_commission_amount
    h.arabic_number(object.commission_amount)
  end

  # Every bill with bill_type `pay` has all it's share_transactions' transaction_type as `sell`
  # Similarly, every bill with bill_type `receive` has all it's share_transactions' transaction_type as `buy`
  def formatted_base_price
    if object.transaction_type == 'sell'
      h.arabic_number(object.base_price)
    else
      'N/A'
    end
  end

  def formatted_capital_gain
    if object.transaction_type == 'sell'
      h.arabic_number(object.cgt)
    else
      'N/A'
    end
  end

  def formatted_commission_rate
    commission_rate = object.commission_rate
    commission_rate = commission_rate == "flat_25" ? "Flat NRs 25" : commission_rate.to_f.to_s + "%"
  end

end
