class Ledgers::ParticularEntry
  include FiscalYearModule
  # create a new particulars
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

  # reverse a particular entry
  def revert(particular, voucher, descr, adjustment)
    process(particular: particular,
            voucher: voucher,
            descr: descr,
            adjustment: adjustment
    )
  end

  # update balances
  def insert_particular(particular)
    ledger = Ledger.find(particular.ledger_id)
    ledger.lock!
    dr_amount = 0
    cr_amount = 0
    opening_balance_org = nil
    opening_balance_cost_center = nil
    fy_code = get_fy_code(particular.transaction_date)
    accounting_date = particular.date

    daily_report_cost_center = LedgerDaily.by_fy_code(fy_code).find_or_create_by!(ledger_id: ledger.id, date: particular.transaction_date, branch_id: particular.branch_id)
    daily_report_org = LedgerDaily.by_fy_code(fy_code).find_or_create_by!(ledger_id: ledger.id, date: particular.transaction_date, branch_id: nil)

    # check if there are records after the entry
    if accounting_date <= Time.now
      ledger_activities = ledger.ledger_dailies.by_fy_code(fy_code).where('date > ?', accounting_date).order('date ASC')
      if ledger_activities.size > 0
        # there are some records after the transaction date
        future_activity_cost_center = ledger_activities.where(branch_id: branch_id).first
        future_activity_org = ledger_activities.where(branch_id: nil).first

        opening_balance_org = future_activity_org.present? ? future_activity_org.opening_balance : 0.0
        opening_balance_cost_center = future_activity_cost_center.present? ? future_activity_cost_center.opening_balance : 0.0

        adjustment_amount = debit ? amount : amount * -1

        ledger_activities.each do |d|
          d.closing_balance += adjustment_amount
          d.opening_balance += adjustment_amount
          d.save!
        end
      end
    end

    ledger_blnc_org = LedgerBalance.by_fy_code(fy_code).find_or_create_by!(ledger_id: ledger.id, branch_id: nil)
    ledger_blnc_cost_center =  LedgerBalance.by_fy_code(fy_code).find_or_create_by!(ledger_id: ledger.id, branch_id: particular.branch_id)
    amount = particular.amount
    if particular.dr?
      dr_amount = amount
      ledger_blnc_org.closing_balance += amount
      ledger_blnc_cost_center.closing_balance += amount
      daily_report_cost_center.closing_balance += amount
      daily_report_org.closing_balance += amount
    else
      ledger_blnc_org.closing_balance -= amount
      ledger_blnc_cost_center.closing_balance -= amount
      daily_report_cost_center.closing_balance -= amount
      daily_report_org.closing_balance -= amount
      cr_amount = amount
    end


    daily_report_cost_center.opening_balance ||= opening_balance_cost_center
    daily_report_cost_center.dr_amount += dr_amount
    daily_report_cost_center.cr_amount += cr_amount
    daily_report_cost_center.save!

    daily_report_org.opening_balance ||= opening_balance_org
    daily_report_org.dr_amount += dr_amount
    daily_report_org.cr_amount += cr_amount
    daily_report_org.save!

    ledger_blnc_org.save!
    ledger_blnc_cost_center.save!

    # particular.opening_balance = closing_balance
    # particular.running_blnc = ledger.closing_balance
    particular.fy_code = get_fy_code(particular.transaction_date)
    particular.complete!
    ledger.save!
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

    # when all branch selected fall back to the user's branch id
    branch_id = UserSession.branch_id if branch_id == 0
    fy_code = voucher.fy_code || UserSession.selected_fy_code

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
    opening_balance_org = nil
    opening_balance_cost_center = nil

    # daily report to store debit and credit transactions
    daily_report_cost_center = LedgerDaily.by_fy_code(fy_code).find_or_create_by!(ledger_id: ledger.id, date: accounting_date, branch_id: branch_id)
    daily_report_org = LedgerDaily.by_fy_code(fy_code).find_or_create_by!(ledger_id: ledger.id, date: accounting_date, branch_id: nil)

    # check if there are records after the entry
    if accounting_date <= Time.now
      ledger_activities = ledger.ledger_dailies.by_fy_code(fy_code).where('date > ?', accounting_date).order('date ASC')
      if ledger_activities.size > 0
        # there are some records after the transaction date
        future_activity_cost_center = ledger_activities.where(branch_id: branch_id).first
        future_activity_org = ledger_activities.where(branch_id: nil).first
        opening_balance_org = future_activity_org.present? ? future_activity_org.opening_balance : 0.0
        opening_balance_cost_center = future_activity_cost_center.present? ? future_activity_cost_center.opening_balance : 0.0

        adjustment_amount = debit ? amount : amount * -1

        ledger_activities.each do |d|
          d.closing_balance += adjustment_amount
          d.opening_balance += adjustment_amount
          d.save!
        end
      end
    end



    # ledger balance by org and cost center
    ledger_blnc_org = LedgerBalance.find_or_create_by!(ledger_id: ledger.id, branch_id: nil)
    ledger_blnc_cost_center =  LedgerBalance.find_or_create_by!(ledger_id: ledger.id, branch_id: branch_id)
    opening_balance_org ||= ledger_blnc_org.opening_balance
    opening_balance_cost_center ||= ledger_blnc_cost_center.opening_balance

    if debit
      dr_amount = amount
      ledger_blnc_org.closing_balance += amount
      ledger_blnc_cost_center.closing_balance += amount
      daily_report_cost_center.closing_balance += amount
      daily_report_org.closing_balance += amount
    else
      ledger_blnc_org.closing_balance -= amount
      ledger_blnc_cost_center.closing_balance -= amount
      daily_report_cost_center.closing_balance -= amount
      daily_report_org.closing_balance -= amount
      cr_amount = amount
    end

    daily_report_cost_center.opening_balance ||= opening_balance_cost_center
    daily_report_cost_center.dr_amount += dr_amount
    daily_report_cost_center.cr_amount += cr_amount
    daily_report_cost_center.save!

    daily_report_org.opening_balance ||= opening_balance_org
    daily_report_org.dr_amount += dr_amount
    daily_report_org.cr_amount += cr_amount
    daily_report_org.save!

    ledger_blnc_org.save!
    ledger_blnc_cost_center.save!

    particular_closing_balance = daily_report_cost_center.closing_balance
    particular_closing_balance_org = daily_report_org.closing_balance

    new_particular = Particular.create!(
        transaction_type: transaction_type,
        ledger_id: ledger.id,
        name: descr,
        voucher_id: voucher.id,
        amount: amount,
        # opening_balance: opening_balance_cost_center,
        # running_blnc: particular_closing_balance,
        # opening_balance_org: opening_balance_org,
        # running_blnc_org: particular_closing_balance_org,
        transaction_date: accounting_date,
        # no option yet for client to segregate reports on the base of cost center
        # not sure if its necessary
        # running_blnc_client: particular_closing_balance_org,
        branch_id: branch_id,
        fy_code: get_fy_code(accounting_date)
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
  #     opening_balance_org = nil
  #     opening_balance_cost_center = nil
  #
  #     # daily report to store debit and credit transactions
  #     daily_report_cost_center = LedgerDaily.find_or_create_by!(ledger_id: ledger.id, date: accounting_date, branch_id: branch_id)
  #     daily_report_org = LedgerDaily.find_or_create_by!(ledger_id: ledger.id, date: accounting_date, branch_id: nil)
  #
  #     ledger.lock!
  #
  #     particular_opening_balance = daily_report.closing_balance
  #     particular_opening_balance_org = daily_report_org.closing_balance
  #
  #     # in case of client account charge the dp fee.
  #     if ledger.client_account_id.present?
  #       amount = amount - adjustment
  #     end
  #
  #     if particular.cr?
  #       dr_amount = amount
  #       daily_report.closing_balance += amount
  #       daily_report_org.closing_balance += amount
  #     else
  #       daily_report.closing_balance -= amount
  #       daily_report_org.closing_balance -= amount
  #       cr_amount = amount
  #     end
  #
  #     daily_report.opening_balance ||= ledger.opening_balance
  #     daily_report.dr_amount += dr_amount
  #     daily_report.cr_amount += cr_amount
  #     daily_report.save!
  #
  #     daily_report_org.opening_balance ||= ledger.opening_balance
  #     daily_report_org.dr_amount += dr_amount
  #     daily_report_org.cr_amount += cr_amount
  #     daily_report_org.save!
  #
  #
  #     particular_closing_balance = daily_report.closing_balance
  #     particular_closing_balance_org = daily_report_org.closing_balance
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
  #         opening_balance: particular_opening_balance,
  #         running_blnc: particular_closing_balance,
  #         opening_balance_org: particular_opening_balance_org,
  #         running_blnc_org: particular_closing_balance_org
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