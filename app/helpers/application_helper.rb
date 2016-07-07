module ApplicationHelper
  # moved the fiscal year module so that it is accesible in modal too
  include FiscalYearModule
  include CustomDateModule
  include NumberFormatterModule
  include MenuPermissionModule

  def link_to_add_fields(name, f, association, extra_info = nil)
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      # render(association.to_s.singularize + "_fields" , f: builder)
      render :partial => association.to_s.singularize + "_fields", :locals => {:f => builder, :extra_info => extra_info}
    end
    link_to(name, '#', class: "add_fields btn btn-primary", data: {id: id, fields: fields.gsub("\n", "")})
  end


  # Get a unique order number based on fiscal year
  # The returned order number is an increment (by 1) of the previously stored order number.
  def get_new_order_number
    order = Order.where(fy_code: get_fy_code).last
    # initialize the orer with 1 if no order is present
    if order.nil?
      1
    else
      # increment the order number
      order.order_number + 1
    end
  end


  # Get a unique bill number based on fiscal year
  # The returned bill number is an increment (by 1) of the previously stored bill_number.
  def get_bill_number
    Bill.new_bill_number(get_fy_code)
  end

  # process accounts to make changes on ledgers
  def process_accounts(ledger, voucher, debit, amount, descr, branch_id, transaction_date = Time.now)
    ledger.lock!
    transaction_type = debit ? Particular.transaction_types['dr'] : Particular.transaction_types['cr']
    # closing_blnc = ledger.closing_blnc
    dr_amount = 0
    cr_amount = 0
    daily_report = LedgerDaily.find_or_create_by!(ledger_id: ledger.id, date: transaction_date.to_date, branch_id: branch_id)
    daily_report_org = LedgerDaily.find_or_create_by!(ledger_id: ledger.id, date: transaction_date.to_date, branch_id: nil)
    particular_opening_blnc = daily_report.closing_blnc
    particular_opening_blnc_org = daily_report_org.closing_blnc

    if debit
      # ledger.closing_blnc += amount
      # ledger.dr_amount += amount
      dr_amount = amount
      daily_report.closing_blnc += amount
      daily_report_org.closing_blnc += amount
    else
      # ledger.closing_blnc -= amount
      # ledger.cr_amount += amount
      daily_report.closing_blnc -= amount
      daily_report_org.closing_blnc -= amount
      cr_amount = amount
    end


    daily_report.opening_blnc ||= ledger.opening_blnc
    daily_report.dr_amount += dr_amount
    daily_report.cr_amount += cr_amount
    daily_report.save!

    daily_report_org.opening_blnc ||= ledger.opening_blnc
    daily_report_org.dr_amount += dr_amount
    daily_report_org.cr_amount += cr_amount
    daily_report_org.save!


    particular_closing_blnc = daily_report.closing_blnc
    particular_closing_blnc_org = daily_report_org.closing_blnc

    particular = Particular.create!(
        transaction_type: transaction_type,
        ledger_id: ledger.id,
        name: descr,
        voucher_id: voucher.id,
        amount: amount,
        opening_blnc: particular_opening_blnc,
        running_blnc: particular_closing_blnc,
        opening_blnc_org: particular_opening_blnc_org,
        running_blnc_org: particular_closing_blnc_org,
        transaction_date: transaction_date,
        # no option yet for client to segregate reports on the base of cost center
        # not sure if its necessary
        running_balance_client: particular_closing_blnc_org,
        branch_id: branch_id
    )
    ledger.save!
    particular
  end

  def reverse_accounts(particular, voucher, descr, adjustment = 0.0)
    amount = particular.amount
    branch_id = particular.branch_id

    # this accounts for the case where whole transaction is cancelled
    # in such case adjustment value is 0
    if (amount - adjustment).abs > 0.01
      transaction_type = particular.cr? ? Particular.transaction_types['dr'] : Particular.transaction_types['cr']
      ledger = particular.ledger
      amount = particular.amount

      daily_report = LedgerDaily.find_by!(ledger_id: ledger.id, date: Time.now.to_date, branch_id: branch_id)
      daily_report_org = LedgerDaily.find_or_create_by!(ledger_id: ledger.id, date: Time.now.to_date, branch_id: nil)

      ledger.lock!

      particular_opening_blnc = daily_report.closing_blnc
      particular_opening_blnc_org = daily_report_org.closing_blnc

      # in case of client account charge the dp fee.
      if ledger.client_account_id.present?
        amount = amount - adjustment
      end

      if particular.cr?
        dr_amount = amount
        daily_report.closing_blnc += amount
        daily_report_org.closing_blnc += amount
      else
        daily_report.closing_blnc -= amount
        daily_report_org.closing_blnc -= amount
        cr_amount = amount
      end

      daily_report.opening_blnc ||= ledger.opening_blnc
      daily_report.dr_amount += dr_amount
      daily_report.cr_amount += cr_amount
      daily_report.save!

      daily_report_org.opening_blnc ||= ledger.opening_blnc
      daily_report_org.dr_amount += dr_amount
      daily_report_org.cr_amount += cr_amount
      daily_report_org.save!


      particular_closing_blnc = daily_report.closing_blnc
      particular_closing_blnc_org = daily_report_org.closing_blnc

      cheque_entries_on_receipt = particular.cheque_entries_on_receipt
      cheque_entries_on_payment = particular.cheque_entries_on_payment

      new_particular = Particular.create!(
          transaction_type: transaction_type,
          ledger_id: ledger.id,
          name: descr,
          voucher_id: voucher.id,
          amount: amount,
          opening_blnc: particular_opening_blnc,
          running_blnc: particular_closing_blnc,
          opening_blnc_org: particular_opening_blnc_org,
          running_blnc_org: particular_closing_blnc_org
      )

      if cheque_entries_on_receipt.size > 0 || cheque_entries_on_payment.size >0
        new_particular.cheque_entries_on_receipt = cheque_entries_on_receipt if cheque_entries_on_receipt.size > 0
        new_particular.cheque_entries_on_payment = cheque_entries_on_payment if cheque_entries_on_payment.size > 0
        new_particular.save!
      end

      ledger.save!
    end


  end

  # method to calculate the broker commission
  def get_broker_commission(commission)
    commission * 0.75
  end

  # method to calculate the tds
  def get_broker_tds(broker_commission)
    broker_commission * 0.15
  end


  # Gets the list of latest price crawled from  http://www.nepalstock.com.np/main/todays_price.
  # In the returned hash, 'isin' is the key and 'price' is the value.
  def get_latest_isin_price_list
    companies = IsinInfo.all

    price_hash = {}
    companies.each do |isin|
      price_hash[isin.isin] = isin.last_price.to_f
    end

    price_hash
  end

  # 	get the margin of error amount
  def margin_of_error_amount
    return 0.01
  end

  # 	get fy_code selection form sesion
  def get_user_selected_fy_code
    session[:user_selected_fy_code]
  end

  # 	set fy_code selection form sesion
  def set_user_selected_fy_code(fy_code)
    fy_code = get_fy_code unless available_fy_codes.include?(fy_code)
    # user session is for model access
    UserSession.selected_fy_code = fy_code
    # session is for controller and view
    session[:user_selected_fy_code] = fy_code
  end

  # 	set fy_code selection form sesion
  def set_user_selected_branch_fy_code(branch_id, fy_code)
    fy_code = get_fy_code unless available_fy_codes.include?(fy_code)
    # user session is for model access
    UserSession.selected_fy_code = fy_code
    # session is for controller and view
    session[:user_selected_fy_code] = fy_code
    session[:user_selected_branch_id] = branch_id
  end




  # @params time - Time object holds time, date and timezone
  def to_ktm_timezone(time)
    time.in_time_zone("Kathmandu")
  end

  # Generically enum, when put in view, has the following form 'first_second', or 'third'. This isn't very pretty to the eyes. Transform to remove underscore and titleize.
  # Modify a string by
  # -replacing underscore '_' with space
  # -titleizing
  def pretty_enum(enum_string)
    str = enum_string.dup
    str.tr!('_', ' ')
    str.titleize
  end
end