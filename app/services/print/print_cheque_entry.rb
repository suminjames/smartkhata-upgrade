class Print::PrintChequeEntry < Prawn::Document
  require 'prawn/table'
  require 'prawn/measurement_extensions'

  include ApplicationHelper

  # def initialize(voucher, particulars, bank_account, cheque, current_tenant)
  def initialize(cheque_entry, name, cheque_date, current_tenant)
    super(top_margin: 1, right_margin: 18, bottom_margin: 18, left_margin: 18)

    @beneficiary_name = name
    @cheque_date = cheque_date
    @cheque_entry = cheque_entry
    @current_tenant = current_tenant

    draw
  end

  def draw
    # Test Data BEGINS
    # ac_payee_note = 'A/C Payee'
    # date = Date.today
    # beneficiary_name = 'Warnakulasuriya Patabendige Ushantha Joseph Chaminda Vaas'
    # amount_in_number = 999999999.99
    # amount_in_word = arabic_word(amount_in_number) + ' only'
    # amount_in_number = arabic_number(amount_in_number)
    # Test Data ENDS

    ac_payee_note = 'A/C Payee'
    date = @cheque_date.strftime("%d-%m-%Y")
    beneficiary_name = @beneficiary_name
    amount_in_number = @cheque_entry.amount
    amount_in_word = arabic_word(amount_in_number) +' only'
    amount_in_number = arabic_number(amount_in_number)

    # Dimensions
    cheque_top = page_height
    cheque_left = 0

    font_size(9) do
      # Left (to the perforation) side of the cheque
      text_box '2519', :at => [cheque_left + 0.9.cm, cheque_top - 1.cm], :width => 2.6.cm # TODO(sarojk) unknown placeholder. apparently has '2519'
      text_box date.to_s, :at => [cheque_left + 0.9.cm, cheque_top - 1.4.cm], :width => 2.6.cm
      text_box beneficiary_name, :at => [cheque_left + 0.9.cm, cheque_top - 1.9.cm], :width => 2.6.cm
      text_box amount_in_number.to_s, :at => [cheque_left + 0.9.cm, cheque_top - 4.5.cm], :width => 2.6.cm
      # Right (to the perforation) side of the cheque
      text_box ac_payee_note, :at => [cheque_left + 11.2.cm, cheque_top - 1.1.cm]
      text_box date.to_s, :at => [cheque_left + 17.9.cm, cheque_top - 1.3.cm]
      text_box beneficiary_name, :at => [cheque_left + 8.8.cm, cheque_top - 2.2.cm], :width => 11.cm
      text_box amount_in_number.to_s, :at => [cheque_left + 17.9.cm, cheque_top - 3.1.cm]
      text_box amount_in_word, :at => [cheque_left + 6.1.cm, cheque_top - 2.9.cm], :width => 9.2.cm
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
