class Ledgers::ParticularEntry
  def insert(ledger, voucher, debit, amount, descr, branch_id, accounting_date)
    process(ledger: ledger,
            voucher: voucher,
            debit: debit,
            amount: amount,
            descr: descr,
            branch_id: branch_id,
            accounting_date: accounting_date
    )
  end
  def revert(particular, voucher, descr, adjustment)
    process(particular: particular,
            voucher: voucher,
            descr: descr,
            adjustment: adjustment
    )
  end
  def process(attrs = {})
    ledger = attrs[:ledger]
    voucher = attrs[:voucher]
    debit = attrs[:debit] || false
    amount =  attrs[:amount]
    descr = attrs[:descr]
    branch_id = attrs[:branch_id]
    accounting_date = attrs[:accounting_date] || Time.now.to_date
    particular = attrs[:particular]
    adjustment = attrs[:adjustment] || 0.0

    # If the case is for revert transaction
    if particular
      amount = particular.amount
      branch_id = particular.branch_id
      # since its a reverse transaction credit will now be a debit
      debit = true if particular.cr?
      ledger = particular.ledger
      amount = particular.amount

      # in case of client account charge the dp fee.
      if ledger.client_account_id.present?
        amount = amount - adjustment
      end
    end

    # this accounts for the case where whole transaction is cancelled
    # in such case adjustment value is 0
    # the case for partial reversal not yet implemented
    return false if particular && (amount - adjustment).abs <= 0.01


    ledger.lock!
    transaction_type = debit ? Particular.transaction_types['dr'] : Particular.transaction_types['cr']

    dr_amount = 0
    cr_amount = 0
    opening_blnc_org = nil
    opening_blnc_cost_center = nil

    # daily report to store debit and credit transactions
    daily_report_cost_center = LedgerDaily.find_or_create_by!(ledger_id: ledger.id, date: accounting_date, branch_id: branch_id)
    daily_report_org = LedgerDaily.find_or_create_by!(ledger_id: ledger.id, date: accounting_date, branch_id: nil)

    # check if there are records after the entry
    if accounting_date <= Time.now
      ledger_activities = ledger.ledger_dailies.where('date > ?', accounting_date).order('date ASC')
      if ledger_activities.size > 0
        # there are some records after the transaction date
        future_activity_cost_center = ledger_activities.where(branch_id: branch_id).first
        future_activity_org = ledger_activities.where(branch_id: nil).first

        opening_blnc_org = future_activity_org.opening_blnc
        opening_blnc_cost_center = future_activity_cost_center.opening_blnc

        adjustment_amount = debit ? amount : amount * -1

        ledger_activities.each do |d|
          d.closing_blnc += adjustment_amount
          d.opening_blnc += adjustment_amount
          d.save!
        end

        particulars = ledger.particulars.where('transaction_date > ?', accounting_date)
        particulars.each do |p|
          p.opening_blnc += adjustment_amount
          p.running_blnc += adjustment_amount
          p.opening_blnc_org += adjustment_amount
          p.running_blnc_org += adjustment_amount
          p.running_blnc_client += adjustment_amount
          p.save!
        end
      end
    end

    opening_blnc_org ||= ledger.opening_blnc
    opening_blnc_cost_center ||= ledger.opening_blnc

    # ledger balance by org and cost center
    ledger_blnc_org = ledger.ledger_balances.find_or_create_by!(branch_id: nil)
    ledger_blnc_cost_center =ledger.ledger_balances.find_or_create_by!(branch_id: branch_id)

    if debit
      dr_amount = amount
      ledger_blnc_org.closing_blnc += amount
      ledger_blnc_cost_center.closing_blnc += amount
      daily_report_cost_center.closing_blnc += amount
      daily_report_org.closing_blnc += amount
    else
      ledger_blnc_org.closing_blnc -= amount
      ledger_blnc_cost_center.closing_blnc -= amount
      daily_report_cost_center.closing_blnc -= amount
      daily_report_org.closing_blnc -= amount
      cr_amount = amount
    end

    daily_report_cost_center.opening_blnc ||= opening_blnc_cost_center
    daily_report_cost_center.dr_amount += dr_amount
    daily_report_cost_center.cr_amount += cr_amount
    daily_report_cost_center.save!

    daily_report_org.opening_blnc ||= opening_blnc_org
    daily_report_org.dr_amount += dr_amount
    daily_report_org.cr_amount += cr_amount
    daily_report_org.save!

    ledger_blnc_org.save!
    ledger_blnc_cost_center.save!

    particular_closing_blnc = daily_report_cost_center.closing_blnc
    particular_closing_blnc_org = daily_report_org.closing_blnc

    new_particular = Particular.create!(
        transaction_type: transaction_type,
        ledger_id: ledger.id,
        name: descr,
        voucher_id: voucher.id,
        amount: amount,
        opening_blnc: opening_blnc_cost_center,
        running_blnc: particular_closing_blnc,
        opening_blnc_org: opening_blnc_org,
        running_blnc_org: particular_closing_blnc_org,
        transaction_date: accounting_date,
        # no option yet for client to segregate reports on the base of cost center
        # not sure if its necessary
        running_blnc_client: particular_closing_blnc_org,
        branch_id: branch_id
    )

    if particular
      cheque_entries_on_receipt = particular.cheque_entries_on_receipt
      cheque_entries_on_payment = particular.cheque_entries_on_payment

      if cheque_entries_on_receipt.size > 0 || cheque_entries_on_payment.size >0
        new_particular.cheque_entries_on_receipt = cheque_entries_on_receipt if cheque_entries_on_receipt.size > 0
        new_particular.cheque_entries_on_payment = cheque_entries_on_payment if cheque_entries_on_payment.size > 0
        new_particular.save!
      end
    end

    ledger.save!
    new_particular
  end


  # def revert(particular, voucher, descr, adjustment = 0.0)
  #   amount = particular.amount
  #   branch_id = particular.branch_id
  #
  #   # this accounts for the case where whole transaction is cancelled
  #   # in such case adjustment value is 0
  #   if (amount - adjustment).abs > 0.01
  #     transaction_type = particular.cr? ? Particular.transaction_types['dr'] : Particular.transaction_types['cr']
  #     ledger = particular.ledger
  #     amount = particular.amount
  #
  #     opening_blnc_org = nil
  #     opening_blnc_cost_center = nil
  #
  #     # daily report to store debit and credit transactions
  #     daily_report_cost_center = LedgerDaily.find_or_create_by!(ledger_id: ledger.id, date: accounting_date, branch_id: branch_id)
  #     daily_report_org = LedgerDaily.find_or_create_by!(ledger_id: ledger.id, date: accounting_date, branch_id: nil)
  #
  #     ledger.lock!
  #
  #     particular_opening_blnc = daily_report.closing_blnc
  #     particular_opening_blnc_org = daily_report_org.closing_blnc
  #
  #     # in case of client account charge the dp fee.
  #     if ledger.client_account_id.present?
  #       amount = amount - adjustment
  #     end
  #
  #     if particular.cr?
  #       dr_amount = amount
  #       daily_report.closing_blnc += amount
  #       daily_report_org.closing_blnc += amount
  #     else
  #       daily_report.closing_blnc -= amount
  #       daily_report_org.closing_blnc -= amount
  #       cr_amount = amount
  #     end
  #
  #     daily_report.opening_blnc ||= ledger.opening_blnc
  #     daily_report.dr_amount += dr_amount
  #     daily_report.cr_amount += cr_amount
  #     daily_report.save!
  #
  #     daily_report_org.opening_blnc ||= ledger.opening_blnc
  #     daily_report_org.dr_amount += dr_amount
  #     daily_report_org.cr_amount += cr_amount
  #     daily_report_org.save!
  #
  #
  #     particular_closing_blnc = daily_report.closing_blnc
  #     particular_closing_blnc_org = daily_report_org.closing_blnc
  #
  #     cheque_entries_on_receipt = particular.cheque_entries_on_receipt
  #     cheque_entries_on_payment = particular.cheque_entries_on_payment
  #
  #     new_particular = Particular.create!(
  #         transaction_type: transaction_type,
  #         ledger_id: ledger.id,
  #         name: descr,
  #         voucher_id: voucher.id,
  #         amount: amount,
  #         opening_blnc: particular_opening_blnc,
  #         running_blnc: particular_closing_blnc,
  #         opening_blnc_org: particular_opening_blnc_org,
  #         running_blnc_org: particular_closing_blnc_org
  #     )
  #
  #     if cheque_entries_on_receipt.size > 0 || cheque_entries_on_payment.size >0
  #       new_particular.cheque_entries_on_receipt = cheque_entries_on_receipt if cheque_entries_on_receipt.size > 0
  #       new_particular.cheque_entries_on_payment = cheque_entries_on_payment if cheque_entries_on_payment.size > 0
  #       new_particular.save!
  #     end
  #
  #     ledger.save!
  #   end
  # end
end