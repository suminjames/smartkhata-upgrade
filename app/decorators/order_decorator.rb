class OrderDecorator < ApplicationDecorator
  delegate_all
  decorates_association :order_details

  # Define presentation-specific methods here. Helpers are accessed through
  # `helpers` (aka `h`). You can override attributes, for example:
  #
  #   def created_at
  #     helpers.content_tag :span, class: 'time' do
  #       object.created_at.strftime("%a %m/%d/%y")
  #     end
  #   end

  def decorate_order_details_to_string
    str = ''
    object.order_details.each do |order_detail|
      str += order_detail.isin_info.isin + '(' + order_detail.quantity.to_s + ')' + '@' + order_detail.price.to_s + ', '
    end
    # Remove the trailing comma and space
    str.slice(0, str.length-2)
  end

end
