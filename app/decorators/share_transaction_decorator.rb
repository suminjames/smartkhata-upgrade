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
    h.number_to_currency (object.share_rate)
  end

  def formatted_amount
    h.number_to_currency(object.share_amount)
  end

  def formatted_commission_amount
    h.number_to_currency(object.commission_amount)
  end

  # TODO Implement the method.
  def formatted_base_price
    'TODO'
  end

  def formatted_commission_rate
    commission_rate = object.commission_rate
    commission_rate = commission_rate == "flat_25" ? "Flat NRs 25" : commission_rate.to_f.to_s + "%"
  end

end
