class OrderRequestsController < ApplicationController
  before_action :set_order_request, only: [:show, :edit, :update, :destroy]

  before_action -> {authorize @order_request}, only: [:show, :edit, :update, :destroy]
  before_action -> {authorize OrderRequest}, only: [:index, :new, :create ]
  
  # GET /order_requests
  # GET /order_requests.json
  def index
    @order_requests = OrderRequest.all
  end

  # GET /order_requests/1
  # GET /order_requests/1.json
  def show
  end

  # GET /order_requests/new
  def new
    @order_request = current_user.client_accounts.first.order_requests.new
    @order_request.order_request_details = [OrderRequestDetail.new]
  end

  # GET /order_requests/1/edit
  def edit
  end

  # POST /order_requests
  # POST /order_requests.json
  def create
    @order_request = OrderRequest.new(order_request_params)

    respond_to do |format|
      if @order_request.save
        format.html { redirect_to order_request_details_path, notice: 'Order request was successfully created.' }
        format.json { render :show, status: :created, location: @order_request }
      else
        format.html { render :new }
        format.json { render json: @order_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /order_requests/1
  # PATCH/PUT /order_requests/1.json
  def update
    respond_to do |format|
      if @order_request.update(order_request_params)
        format.html { redirect_to @order_request, notice: 'Order request was successfully updated.' }
        format.json { render :show, status: :ok, location: @order_request }
      else
        format.html { render :edit }
        format.json { render json: @order_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /order_requests/1
  # DELETE /order_requests/1.json
  def destroy
    @order_request.destroy
    respond_to do |format|
      format.html { redirect_to order_requests_url, notice: 'Order request was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order_request
      @order_request = OrderRequest.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_request_params
      params.require(:order_request).permit(:client_account_id, :date_bs, order_request_details_attributes: [:id, :isin_info_id, :client_account_id, :rate, :quantity, :order_type ])
    end
end
