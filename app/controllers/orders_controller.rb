class OrdersController < ApplicationController
  before_action -> {authorize Order}
  helper_method :is_active_sub_menu_option

  def index
    @filterrific = initialize_filterrific(
        Order,
        params[:filterrific],
        select_options: {
          by_client_id: ClientAccount.options_for_client_select(params[:filterrific]),
        },
        persistence_id: false
    ) or return
    items_per_page = params[:paginate] == 'false' ? Order.count : 20
    @orders = @filterrific.find.includes(:client_account, [order_details: :isin_info]).page(params[:page]).per(items_per_page)

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
