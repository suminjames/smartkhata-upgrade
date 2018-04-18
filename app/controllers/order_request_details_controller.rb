class OrderRequestDetailsController < ApplicationController
  before_action :set_order_request_detail, only: [:approve, :show, :edit, :update, :destroy, :reject]

  before_action -> {authorize @order_request_detail}, only: [:show, :edit, :update, :destroy, :approve, :reject]
  before_action -> {authorize OrderRequestDetail}, only: [:index, :client_report, :new, :create]

  # GET /order_request_details
  # GET /order_request_details.json
  def index

    # different page for officials
    if current_user.is_official?
      # @order_request_details = OrderRequestDetail.todays_order.pending
      @order_request_details = OrderRequestDetail.pending
      render 'index_official' and return
    end

    @filterrific = initialize_filterrific(
        OrderRequestDetail,
        params[:filterrific],
        select_options: {
            with_company_id: IsinInfo.options_for_isin_info_select(params[:filterrific]),
            by_sector: IsinInfo.options_for_sector_select,
            with_status: OrderRequestDetail.statuses
        },
        persistence_id: false
    ) or return
    @order_request_details = @filterrific.find.client_order(current_user.id).page(params[:page]).per(20)
    @client_account_id = ClientAccount.find_by(user_id: current_user.id)&.id
  rescue RuntimeError => e
    puts "Had to reset filterrific params: #{ e.message }"
    respond_to do |format|
      flash.now[:error] = "#{ e.message }"
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

  def client_report
    @filterrific = initialize_filterrific(
        OrderRequestDetail.branch_scoped,
        params[:filterrific],
        select_options: {
            with_company_id: IsinInfo.options_for_isin_info_select(params[:filterrific]),
            with_client_id: ClientAccount.options_for_client_select(params[:filterrific]),
            by_sector: IsinInfo.options_for_sector_select,
            with_status: OrderRequestDetail.statuses
        },
        persistence_id: false
    ) or return
    @order_request_details = @filterrific.find.page(params[:page]).per(20)
  rescue RuntimeError => e
    puts "Had to reset filterrific params: #{ e.message }"
    respond_to do |format|
      flash.now[:error] = "#{ e.message }"
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


  def approve
    @order_request_detail.update_attribute(:status, OrderRequestDetail.statuses[:acknowledged])
    respond_to do |format|
      format.html { redirect_to order_request_details_url, notice: 'Order request was successfully approved.' }
      format.json { head :no_content }
    end
  end

  def reject
    @order_request_detail.update_attribute(:status, OrderRequestDetail.statuses[:rejected])
    respond_to do |format|
      format.html { redirect_to order_request_details_url, notice: 'Order request was successfully rejected.' }
      format.json { head :no_content }
    end
  end

  # GET /order_request_details/1
  # GET /order_request_details/1.json
  def show
  end

  # GET /order_request_details/new
  def new
    @order_request_detail = OrderRequestDetail.new
  end

  # GET /order_request_details/1/edit
  def edit
  end

  # POST /order_request_details.json
  def create
    @order_request_detail = OrderRequestDetail.new(order_request_detail_params)

    respond_to do |format|
      if @order_request_detail.save
        format.html { redirect_to @order_request_detail, notice: 'Order request detail was successfully created.' }
        format.json { render :show, status: :created, location: @order_request_detail }
      else
        format.html { render :new }
        format.json { render json: @order_request_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /order_request_details/1
  # PATCH/PUT /order_request_details/1.json
  def update
    respond_to do |format|
      if @order_request_detail.update(order_request_detail_params)
        format.html { redirect_to order_request_details_path, notice: 'Order request detail was successfully updated.' }
        format.json { render :show, status: :ok, location: @order_request_detail }
      else
        format.html { render :edit }
        format.json { render json: @order_request_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /order_request_details/1
  # DELETE /order_request_details/1.json
  def destroy

    @order_request_detail.soft_delete
    respond_to do |format|
      format.html { redirect_to order_request_details_url, notice: 'Order request was successfully destroyed.' }
      format.json { head :no_content }
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order_request_detail
      @order_request_detail = OrderRequestDetail.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_request_detail_params
      params.require(:order_request_detail).permit(:quantity, :rate, :status, :isin_info_id, :order_request_id)
    end
end
