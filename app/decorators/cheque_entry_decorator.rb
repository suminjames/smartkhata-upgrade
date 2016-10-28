class ChequeEntryDecorator < ApplicationDecorator
  decorates :cheque_entry
  delegate_all

  def formatted_status_indicator_class
    cheque_entry = object
    if cheque_entry.printed?
      css_klass = 'cheque-entry-printed'
    else
      if cheque_entry.receipt? || cheque_entry.unassigned? || cheque_entry.void?
        css_klass = 'cheque-entry-unprintable'
      else
        css_klass = 'cheque-entry-not-printed'
      end
    end
    "cheque-entry-indicator #{css_klass}"
  end

  def formatted_check_box_class
    cheque_entry = object
    check_box_classes = []
    check_box_classes << 'cheque-entry'
    check_box_classes << 'unprintable-cheque' if !cheque_entry.can_print_cheque?
    check_box_classes << 'receipt-cheque' if cheque_entry.receipt?
    check_box_classes << 'payment-cheque' if cheque_entry.payment?
    check_box_classes << 'unassigned-cheque' if cheque_entry.unassigned?
    check_box_classes.join(" ")
  end

  #
  # For time being, pending_clearance need not be shown in the view.
  # pending_clearance will be used later to verify and record bank reconciliation.
  #
  def formatted_status
    cheque_entry = object
    status = ''
    if cheque_entry.receipt? && cheque_entry.pending_clearance?
      status = 'N/A'
    else
      status = h.pretty_enum(cheque_entry.status)
    end
    status
  end

end
