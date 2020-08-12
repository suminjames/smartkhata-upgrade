class Ledgers::ParticularEntry
  include FiscalYearModule
  # create a new particulars

  attr_reader :current_user_id

  def initialize(current_user_id)
    @current_user_id = current_user_id
  end

  def insert(ledger, value_date, voucher, debit, amount, descr, branch_id, accounting_date,current_user_id)
    process(ledger: ledger,
            voucher: voucher,
            debit: debit,
            amount: amount,
            descr: descr,
            branch_id: branch_id,
            value_date: value_date,
            accounting_date: accounting_date,
            creator_id: current_user_id,
            updater_id: current_user_id,
            current_user_id: current_user_id
    )
  end

  # reverse a particular entry
  def revert(particular, voucher, descr, adjustment, reversed_cheque_entry, current_user_id)
    process(particular: particular,
            voucher: voucher,
            descr: descr,
            adjustment: adjustment,
            reversed_cheque_entry: reversed_cheque_entry,
            current_user_id: current_user_id
    )
  end

  # update balances
  def insert_particular(particular)
    ledger = Ledger.find(particular.ledger_id)
    fy_code = get_fy_code(particular.transaction_date)
    accounting_date = particular.transaction_date
    calculate_balances(ledger, accounting_date, particular.dr?, particular.amount, fy_code, particular.branch_id, current_user_id)
    particular.fy_code = fy_code
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
    reversed_cheque_entry = attrs[:reversed_cheque_entry]
    value_date = attrs[:value_date]
    creator_id = attrs[:creator_id]
    updater_id = attrs[:updater_id]
    current_user_id = attrs[:current_user_id]
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
      accounting_date = voucher.date
      # in case of client account charge the dp fee.
      if ledger.client_account_id.present?
        amount = amount - adjustment
      end
    end

    # this accounts for the case where whole transaction is cancelled
    # in such case adjustment value is 0
    # the case for partial reversal not yet implemented
    return false if particular && (amount - adjustment).abs <= 0.01

    transaction_type = debit ? Particular.transaction_types['dr'] : Particular.transaction_types['cr']
    calculate_balances(ledger, accounting_date, debit, amount, fy_code, branch_id, current_user_id)
    new_particular = Particular.create!(
        transaction_type: transaction_type,
        ledger_id: ledger.id,
        name: descr,
        voucher_id: voucher.id,
        amount: amount,
        transaction_date: accounting_date,
        branch_id: branch_id,
        fy_code: get_fy_code(accounting_date),
        value_date: value_date,
        creator_id: creator_id,
        updater_id: updater_id,
        current_user_id: current_user_id
        )

    if particular
      cheque_entries_on_receipt = particular.cheque_entries_on_receipt
      cheque_entries_on_payment = particular.cheque_entries_on_payment

      if reversed_cheque_entry
        new_particular.cheque_entries_on_reversal << reversed_cheque_entry
        new_particular.save!
      else
        if cheque_entries_on_receipt.size > 0 || cheque_entries_on_payment.size >0
          new_particular.cheque_entries_on_receipt = cheque_entries_on_receipt if cheque_entries_on_receipt.size > 0
          new_particular.cheque_entries_on_payment = cheque_entries_on_payment if cheque_entries_on_payment.size > 0
          new_particular.save!
        end
      end
    end

    ledger.save!
    new_particular
  end


  def calculate_balances(ledger, accounting_date, debit, amount, fy_code, branch_id, current_user_id)
    ledger.lock!
    dr_amount = 0
    cr_amount = 0
    opening_balance_org = nil
    opening_balance_cost_center = nil
    set_current_user = lambda { |o| o.current_user_id = current_user_id }

    # need to do the unscoped here for matching the ledger balance
    ledger_blnc_org = LedgerBalance.by_fy_code_org(fy_code)
                        .find_or_create_by!(ledger_id: ledger.id, &set_current_user).tap(&set_current_user)
    ledger_blnc_cost_center =  LedgerBalance.by_branch_fy_code(branch_id, fy_code)
                                 .find_or_create_by!(ledger_id: ledger.id, &set_current_user).tap(&set_current_user)


    opening_balance_org ||= ledger_blnc_org.closing_balance
    opening_balance_cost_center ||= ledger_blnc_cost_center.closing_balance



    daily_report_cost_center = LedgerDaily.by_branch_fy_code(branch_id,fy_code).find_or_create_by!(ledger_id: ledger.id, date: accounting_date) do |l|
      l.current_user_id = current_user_id
    end.tap(&set_current_user)

    daily_report_org = LedgerDaily.by_fy_code_org(fy_code).find_or_create_by!(ledger_id: ledger.id, date: accounting_date) do |l|
      l.current_user_id = current_user_id
    end.tap(&set_current_user)

    if debit
      dr_amount = amount
      ledger_blnc_org.closing_balance += amount
      ledger_blnc_cost_center.closing_balance += amount
    else
      ledger_blnc_org.closing_balance -= amount
      ledger_blnc_cost_center.closing_balance -= amount
      cr_amount = amount
    end
    daily_report_cost_center.dr_amount += dr_amount
    daily_report_cost_center.cr_amount += cr_amount
    daily_report_cost_center.save!

    daily_report_org.dr_amount += dr_amount
    daily_report_org.cr_amount += cr_amount
    daily_report_org.save!
#
    ledger_blnc_org.dr_amount += dr_amount
    ledger_blnc_org.cr_amount += cr_amount
    ledger_blnc_cost_center.dr_amount += dr_amount
    ledger_blnc_cost_center.cr_amount += cr_amount
    ledger_blnc_org.save!
    ledger_blnc_cost_center.save!

    ledger.save!
  end
end
