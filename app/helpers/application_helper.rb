module ApplicationHelper
  # moved the fiscal year module so that it is accesible in modal too
  include FiscalYearModule
  include CustomDateModule
  include NumberFormatterModule
  include MenuPermissionModule
  include BranchPermissionModule

  def link_to_add_fields(name, f, association, extra_info = nil)
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      # render(association.to_s.singularize + "_fields" , f: builder)
      render :partial => association.to_s.singularize + "_fields", :locals => {:f => builder, :extra_info => extra_info}
    end
    link_to(name, '#', class: "add_fields btn btn-info btn-flat", data: {id: id, fields: fields.gsub("\n", "")})
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
  def get_bill_number(fy_code = get_fy_code)
    Bill.new_bill_number(fy_code)
  end

  # process accounts to make changes on ledgers
  def process_accounts(ledger, voucher, debit, amount, descr, branch_id, transaction_date)
   Ledgers::ParticularEntry.new.insert(ledger, voucher, debit, amount, descr, branch_id,transaction_date)
  end

  def reverse_accounts(particular, voucher, descr, adjustment = 0.0)
    Ledgers::ParticularEntry.new.revert(particular, voucher, descr, adjustment = 0.0)
  end

  # method to calculate the broker commission
  def get_broker_commission(commission)
    commission * 0.75
  end

  # method to calculate the tds
  def get_broker_tds(broker_commission)
    broker_commission * 0.15
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

    # session is for controller and view
    session[:user_selected_fy_code] = fy_code
    session[:user_selected_branch_id] = branch_id

    UserSession.selected_fy_code = session[:user_selected_fy_code]
    UserSession.selected_branch_id = session[:user_selected_branch_id]
  end


  # get available branches
  def available_branches
    Branch.all
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


  # For serial number in element listing to work properly with kaminari pagination
  def kaminari_serial_number(page_number, per_page)
    params[:page].blank? ? 1 : ((page_number.to_i - 1) * per_page) + 1
  end
end