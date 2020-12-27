class ShareTransactionDecorator < ApplicationDecorator
  delegate_all

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

  # Every bill with bill_type `pay` has all it's share_transactions' transaction_type as `selling`
  # Similarly, every bill with bill_type `receive` has all it's share_transactions' transaction_type as `buying`
  def formatted_base_price
    if object.transaction_type == 'selling'
      h.arabic_number(object.base_price)
    else
      'N/A'
    end
  end

  def formatted_capital_gain
    if object.transaction_type == 'selling'
      h.arabic_number(object.cgt)
    else
      'N/A'
    end
  end

  def formatted_commission_rate
    commission_rate = object.commission_rate
    if commission_rate == "flat_25"
      "Flat NRs 25"
    elsif commission_rate == "flat_10"
      "Flat NRs 10"
    else
      commission_rate.to_f.to_s + "%"
    end
  end

  def formatted_status_indicator_class
    object.closeout_settled? ? "share_transaction" : "share_transaction indicator-bg-light-red"
  end
end
