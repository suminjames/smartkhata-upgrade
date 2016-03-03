class BillsController < ApplicationController
  before_action :set_bill, only: [:show, :edit, :update, :destroy]

  # GET /bills
  # GET /bills.json
  def index
    if params[:search_by] && params[:search_term]
      @bills = Bill.search(params[:search_by], params[:search_term]).order(:bill_number).paginate(:page => params[:page], :per_page => 30)
      else
        #Order bills as per bill_number and not updated_at(which is the metric for default ordering)
        @bills = Bill.order(:bill_number).paginate(:page => params[:page], :per_page => 30)
    end
  end

  # GET /bills/1
  # GET /bills/1.json
  def show
    #TODO Display 'Bill not found if invalid Id'
    @bill
  end

  # GET /bills/new
  def new
    @bill = Bill.new
  end

  # GET /bills/1/edit
  def edit
  end

  # POST /bills
  # POST /bills.json
  def create
    @bill = Bill.new(bill_params)

    respond_to do |format|
      if @bill.save
        format.html { redirect_to @bill, notice: 'Bill was successfully created.' }
        format.json { render :show, status: :created, location: @bill }
      else
        format.html { render :new }
        format.json { render json: @bill.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /bills/1
  # PATCH/PUT /bills/1.json
  def update
    respond_to do |format|
      if @bill.update(bill_params)
        format.html { redirect_to @bill, notice: 'Bill was successfully updated.' }
        format.json { render :show, status: :ok, location: @bill }
      else
        format.html { render :edit }
        format.json { render json: @bill.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bills/1
  # DELETE /bills/1.json
  def destroy
    @bill.destroy
    respond_to do |format|
      format.html { redirect_to bills_url, notice: 'Bill was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_bill
      # @bill = Bill.find(params[:id])
      # Used 'find_by_id' instead of 'find' to as the former returns nil if the object with the id not found
      # The bang operator '!' after find_by_id raises an error and halts the script
      @bill = Bill.find_by_id!(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def bill_params
      params.fetch(:bill, {})
    end
end
