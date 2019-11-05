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
      render :partial => association.to_s.singularize + "_fields", :locals => {:f => builder, :extra_info => extra_info, sk_id: id}
    end
    link_to(name, '#', class: "add_fields btn btn-info btn-flat", data: {id: id, fields: fields.gsub("\n", "")})
  end


  # Get a unique order number based on fiscal year
  # The returned order number is an increment (by 1) of the previously stored order number.
  def get_new_order_number
    order = Order.where(fy_code: get_fy_code).last
    # initialize the order with 1 if no order is present
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

  def reverse_accounts(particular, voucher, descr, adjustment = 0.0, cheque_entry = nil)
    Ledgers::ParticularEntry.new.revert(particular, voucher, descr, adjustment = 0.0, cheque_entry)
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

  def equal_amounts?(amount_a, amount_b)
    (amount_a.to_d - amount_b.to_d).abs <= margin_of_error_amount
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
    # available_branches_for_user(current_user)
    current_user.available_branches
  end

  # get the branches that are available for the user
  # for admin and client all the branch are available
  # for employee only those assigned on the permission
  def available_branches_for_user(current_user)
    _available_branches = []
    if current_user
      if current_user.admin? || current_user.client?
        _available_branches = Branch.all
      else
        branch_ids = current_user.branch_permissions.pluck(:branch_id)
        _available_branches = Branch.where(id: branch_ids)
      end
    end
    _available_branches
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
    enum_string ||= ''
    str = enum_string.dup
    str.tr!('_', ' ')
    str.titleize
  end


  # For serial number in element listing to work properly with kaminari pagination
  def kaminari_serial_number(page_number, per_page)
    params[:page].blank? ? 1 : ((page_number.to_i - 1) * per_page) + 1
  end

  def admin_and_above?
    current_user.admin? || current_user.sys_admin?
  end

  def can_invite_users?
    user_has_access_to?(client_accounts_path(invite: true))
  end

  def get_user_name_from_boid(boid)
    new_boid = boid[-8,8]
    new_boid.sub!(/^[0]+/,'')
    unless new_boid.length >= 4
      new_boid = boid[-4,4]
    end
    new_boid
  end

  def get_common_name_from_dn(string)
    # /C=NP/ST=Bagmati/L=Kathmandu/O=Trishakti Securities/OU=Web/CN=Client
    unless string.blank?
      string_arr = string.split('/')
      cn_arr = string_arr.select{|x| (x =~ /CN=/).present? }
      if cn_arr.first.present?
        cn_key_pair = cn_arr.first
        return cn_key_pair.split('=')[1]
      end
    end
    nil
  end

  def valid_certificate? user
    # return false if request.headers.env["HTTP_X_CLIENT_VERIFY"] != 'SUCCESS'
    #
    # if Rails.env.production?
    #   return false if user.client? && get_common_name_from_dn(request.headers.env["HTTP_X_CLIENT_DN"]) != 'smartkhata_client'
    #   return false if !user.client? && get_common_name_from_dn(request.headers.env["HTTP_X_CLIENT_DN"]) != 'smartkhata_employee'
    # end
    true
  end

  def can_view_restricted_ledgers?
    user_has_access_to?(restricted_ledgers_path)
  end

  def navbar_color
    return if current_user.nil?

    branch = Branch.selected_branch

    return if branch.nil?

    branch.top_nav_bar_color
  end
end