class OrderRequestDetailsController < ApplicationController
  before_action :set_order_request_detail, only: [:show, :edit, :update, :destroy]

  before_action -> {authorize @order_request_detail}, only: [:show, :edit, :update, :destroy]
  before_action -> {authorize OrderRequestDetail}, only: [:index, :new, :create]

  # GET /order_request_details
  # GET /order_request_details.json
  def index
    @order_request_details = OrderRequestDetail.todays_order
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
