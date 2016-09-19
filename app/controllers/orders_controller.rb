class OrdersController < ApplicationController

  helper_method :is_active_sub_menu_option

  def index
    # Trying to implement filterrific
    @filterrific = initialize_filterrific(
        Order,
        params[:filterrific],
        select_options: {
            by_client_id: ClientAccount.options_for_client_select(params[:filterrific]),
            # by_order_number: Order.options_for_bank_account_select, # text field
            # by_client_id: Order.options_for_client_select,
        },
        persistence_id: false
    ) or return
    items_per_page = params[:paginate] == 'false' ? Order.count : 20
    @orders = @filterrific.find.includes(:client_account, [order_details: :isin_info]).page(params[:page]).per(items_per_page)
    # debugger
    respond_to do |format|
      format.html
      format.js
    end

    # Recover from 'invalid date' error in particular, among other RuntimeErrors.
    # OPTIMIZE(sarojk): Propagate particular error to specific field inputs in view.
  rescue RuntimeError => e
    puts "Had to reset filterrific params: #{ e.message }"
    respond_to do |format|
      flash.now[:error] = 'One of the search options provided is invalid.'
      format.html { render :index }
      format.json { render json: flash.now[:error], status: :unprocessable_entity }
    end

    # Recover from invalid param sets, e.g., when a filter refers to the
    # database id of a record that doesn’t exist any more.
    # In this case we reset filterrific and discard all filter params.
  rescue ActiveRecord::RecordNotFound => e
    # There is an issue with the persisted param_set. Reset it.
    puts "Had to reset filterrific params: #{ e.message }"
    redirect_to(reset_filterrific_url(format: :html)) and return


=begin
    # Old filterrific implementation
    @selected_client_for_combobox_in_arr = []

    # Empty @orders if none of the following conditions is matched
    @orders = []

    if params[:search_term].present?

      if params[:search_by] == 'client_name'
        @orders = Order.order(:id).find_by_client_id(params[:search_term])
        client_account = ClientAccount.find_by_id(params[:search_term])
        @selected_client_for_combobox_in_arr = [client_account] if client_account
      end

      if params[:search_by] == 'order_number'
        @orders = Order.order(:id).find_by_order_number(params[:search_term])
      end

      if params[:search_by] == 'date'
        # The date being entered are assumed to be BS date, not AD date
        date_bs = params[:search_term]
        if parsable_date? date_bs
          date_ad = bs_to_ad(date_bs)
          @orders = Order.find_by_date(date_ad)
        else
          respond_to do |format|
            format.html { render :index }
            flash.now[:error] = 'Invalid date'
            format.json { render json: flash.now[:error], status: :unprocessable_entity }
          end
        end
      end

      if params[:search_by] == 'date_range'
        # The dates being entered are assumed to be BS dates, not AD dates
        date_from_bs = params['search_term']['date_from']
        date_to_bs = params['search_term']['date_to']
        # OPTIMIZE: Notify front-end of the particular date(s) invalidity
        if parsable_date?(date_from_bs) && parsable_date?(date_to_bs)
          date_from_ad = bs_to_ad(date_from_bs)
          date_to_ad = bs_to_ad(date_to_bs)
          @orders = Order.find_by_date_range(date_from_ad, date_to_ad)
        else
          respond_to do |format|
            flash.now[:error] = 'Invalid date(s)'
            format.html { render :index }
            format.json { render json: flash.now[:error], status: :unprocessable_entity }
          end
        end
      end

    end

    if params[:search_by] == 'all_orders'
      @orders = Order.all.includes(:order_details, :client_account).page(params[:page]).per(20)
    end

    @orders = @orders.page(params[:page]).per(20) if @orders.present?
=end

  end

  def show
    @from_path = request.referer
    @order= Order.find(params[:id])
  end

  # This method is used by view to figure out which one of the sub-menus is active as per the params
  def is_active_sub_menu_option(option)
    return params[:search_by] == option
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_order
    # @order = Order.find(params[:id])
    # Used 'find_by_id' instead of 'find' to as the former returns nil if the object with the id not found
    # The bang operator '!' after find_by_id raises an error and halts the script
    @order = Order.find_by_id!(params[:id]).decorate
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def order_params
    params.fetch(:order, {})
  end

end
