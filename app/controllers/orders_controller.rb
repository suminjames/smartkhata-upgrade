class OrdersController < ApplicationController

  helper_method :is_active_sub_menu_option

  def index
    # default landing action for '/orders'
    if params[:search_by].blank?
      respond_to do |format|
        format.html { redirect_to orders_path(search_by: "client_name") }
      end
      return
    end

    # Instance variable used by combobox in view to populate name
    if params[:search_by] == 'client_name'
      @clients_for_combobox = ClientAccount.all.order(:name)
    end

    # Empty @orders if none of the following conditions is matched
    @orders = []

    if params[:search_term].present?

      if params[:search_by] == 'client_name'
        @orders = Order.order(:id).find_by_client_id(params[:search_term])
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
        date_to_bs   = params['search_term']['date_to']
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

    # @orders = @orders.page(params[:page]).per(20).decorate if @orders.present?

  end

  def show
    @from_path =  request.referer
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
