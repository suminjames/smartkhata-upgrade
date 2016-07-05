# Note:
# - US Letter Dimension:  8.5 by 11.0 inches (215.9 by 279.4 mm)
# - A4 Dimenstion:        8.3 by 11.7 inches (210 by 297 mm)
# - Cheque Dimension:
#                         Perforated strips (left + right) = (1.35 + 1.35)cm = 27mm
#                         Cheque with perforated strips = 25.6cm = 256mm
#                         Cheque without perforated strips = 256mm - 27mm = 229mm
#                         Overall Page = (256 by 89 mm)  => ( 725.65 by 252.28 pdf-points)
#     Important! Cheque Dimension is actually US letter size, if the right most past-perforated section is ignored.
class Print::PrintMultipleChequeEntries < Prawn::Document
  require 'prawn/table'
  require 'prawn/measurement_extensions'

  include ApplicationHelper

  def initialize(cheque_entries, current_tenant)
    super(:page_size => [page_width, page_height], top_margin: 1, right_margin: 18, bottom_margin: 18, left_margin: 18)

    @current_tenant = current_tenant

    cheque_entries.each_with_index do |cheque_entry, index|
      @cheque_entry = cheque_entry

      # Code borrowed from ChequeEntry#show action BEGINS
      # Important! Future changes to the aforementioned action should also be reflected (manually) here.
      if @cheque_entry.additional_bank_id.present?
        @bank = Bank.find_by(id: @cheque_entry.additional_bank_id)
        @name = current_tenant.full_name
      else
        @bank = @cheque_entry.bank_account.bank
        @name = @cheque_entry.beneficiary_name.present? ? @cheque_entry.beneficiary_name : "Internal Ledger"
      end
      @cheque_date = @cheque_entry.cheque_date.nil? ? DateTime.now : @cheque_entry.cheque_date
      # Code borrowed from ChequeEntry#show action ENDS

      @beneficiary_name = @name
      @cheque_date = @cheque_date

      draw

      if index != cheque_entries.length - 1
        start_new_page
      end
    end

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
    cheque_top = page_height - 0.8.cm
    cheque_left = -1.2.cm

    font_size(9) do
      # Left (to the perforation) side of the cheque
      text_box date.to_s, :at => [cheque_left + 0.9.cm, cheque_top - 1.6.cm], :width => 2.6.cm
      text_box beneficiary_name, :at => [cheque_left + 0.9.cm, cheque_top - 2.1.cm], :width => 2.6.cm
      text_box amount_in_number.to_s, :at => [cheque_left + 0.9.cm, cheque_top - 4.7.cm], :width => 2.6.cm
      # Right (to the perforation) side of the cheque
      text_box ac_payee_note, :at => [cheque_left + 11.2.cm, cheque_top - 1.1.cm]
      text_box date.to_s, :at => [cheque_left + 17.9.cm, cheque_top - 1.0.cm]
      text_box beneficiary_name, :at => [cheque_left + 8.8.cm, cheque_top - 2.2.cm], :width => 11.cm
      text_box amount_in_number.to_s, :at => [cheque_left + 17.9.cm, cheque_top - 3.0.cm]
      text_box amount_in_word, :at => [cheque_left + 6.1.cm, cheque_top - 2.9.cm], :width => 9.2.cm
    end
  end

# - US Letter Dimension:  8.5 by 11.0 inches (215.9 by 279.4 mm)
  def page_width
    216.9.mm
  end

  def page_height
    90.mm
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
