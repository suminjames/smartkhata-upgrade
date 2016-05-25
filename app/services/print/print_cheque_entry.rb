class Print::PrintChequeEntry < Prawn::Document
  require 'prawn/table'
  require 'prawn/measurement_extensions'

  include ApplicationHelper

  # def initialize(voucher, particulars, bank_account, cheque, current_tenant)
  def initialize(cheque, current_tenant)
    super(top_margin: 1, right_margin: 18, bottom_margin: 18, left_margin: 18)

    @cheque = cheque
    @current_tenant = current_tenant

    draw
  end

  def draw
    font_size(9) do
    #   TODO(sarojk)
    end
  end

  def page_width
    578
  end

  def page_height
    770
  end

  def col (unit)
    unit / 12.0 * page_width
  end

  def hr
    pad_bottom(3) do
      stroke_horizontal_rule
    end
  end

end
