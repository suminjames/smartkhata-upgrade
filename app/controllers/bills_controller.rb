class BillsController < ApplicationController
  before_action :set_bill, only: [:show, :edit, :update, :destroy]

  # GET /bills
  # GET /bills.json
  def index
    #default landing action for '/bills' should redirect to '/bills?search_by=bill_status&search_term=unsettled_bills'
    # abort params.count.to_s
    # render action: index, search_by: "bill_status", search_term: "unsettled_bills" if params[:search_term].nil?
    if params[:search_by].blank?
      respond_to do |format|
        format.html { redirect_to bills_path( search_by: "bill_status", search_term: "unsettled_bills") }
      end
      return
    end
    if params[:search_by] && params[:search_term]
      search_by = params[:search_by]
      search_term = params[:search_term]
      case search_by
      when 'client_name'
        @bills = Bill.find_by_client_name(search_term)
      when 'bill_number'
        @bills = Bill.find_by_bill_number(search_term)
      when 'bill_status'
        @bills = Bill.find_not_settled
      when 'bill_type'
        type = search_term
        @bills = Bill.find_by_bill_type(type)
      when 'date'
        date = search_term
        if parsable_date? date
          @bills = Bill.find_by_date(Date.parse(date))
        else
          @bills = ''
          respond_to do |format|
            format.html { render :index }
            flash.now[:error] = 'Invalid date'
            format.json { render json: flash.now[:error], status: :unprocessable_entity }
          end
        end
      when 'date_range'
        date_from = search_term['date_from']
        date_to   = search_term['date_to']
        # OPTIMIZE: Notify front-end of the particular date(s) invalidity
        if parsable_date?(date_from) && parsable_date?(date_to)
          date_from = Date.parse(date_from)
          date_to   = Date.parse(date_to)
          @bills = Bill.find_by_date_range(date_from, date_to)
        else
          @bills = ''
          respond_to do |format|
            flash.now[:error] = 'Invalid date(s)'
            format.html { render :index }
            format.json { render json: flash.now[:error], status: :unprocessable_entity }
          end
        end
      end
    elsif params[:show] == 'all'
      # Order bills as per bill_number and not updated_at(which is the metric for default ordering)
      @bills = Bill
    else
      @bills = ''
    end
    # Order bills as per bill_number and not updated_at(which is the metric for default ordering)
    @bills = @bills.order(:bill_number).page(params[:page]).per(20).decorate unless @bills.blank?
  end

  # GET /bills/1
  # GET /bills/1.json
  def show
    @from_path =  request.referer
    @bill = Bill.find(params[:id]).decorate
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
    @bill = Bill.find_by_id!(params[:id]).decorate
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def bill_params
    params.fetch(:bill, {})
  end

end
