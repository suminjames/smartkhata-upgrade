class LedgersController < ApplicationController
  before_action :set_ledger, only: [:show, :edit, :update, :destroy]

  # GET /ledgers
  # GET /ledgers.json
  def index
    #default landing action for '/ledgers'
    # OPTIMIZE - Refactor
    if params[:show].blank? && params[:search_by].blank?
      respond_to do |format|
        format.html { redirect_to ledgers_path(search_by: "ledger_name") }
      end
      return
    end
    if params[:show] == "all"
      @ledgers = Ledger.all.includes(:client_account)
    elsif params[:show] == "all_client"
      @ledgers = Ledger.includes(:client_account).find_all_client_ledgers
    elsif params[:show] == "all_internal"
      @ledgers = Ledger.includes(:client_account).find_all_internal_ledgers
    elsif params[:search_by] && params[:search_term]
      search_by = params[:search_by]
      search_term = params[:search_term]
      case search_by
      when 'ledger_name'
        ledger_name = search_term
        @ledgers = Ledger.includes(:client_account).find_by_ledger_name(ledger_name)
      else
        # If no matches for case  'search_by', return empty @ledgers
        @ledgers = ''
      end
    else
      @ledgers = ''
    end
    # Order ledgers as per ledger_name and not updated_at(which is the metric for default ordering)
    # TODO chain .decorate function
    @ledgers = @ledgers.order(:name).page(params[:page]).per(20) unless @ledgers.blank?
  end

  # GET /ledgers/1
  # GET /ledgers/1.json
  def show
    @particulars = @ledger.particulars.complete.order("id ASC")
  end

  # GET /ledgers/new
  def new
    @ledger = Ledger.new
  end

  # GET /ledgers/1/edit
  def edit
  end

  # POST /ledgers
  # POST /ledgers.json
  def create
    @ledger = Ledger.new(ledger_params)
    @success = false
    if (@ledger.opening_blnc >= 0)
      @success = true if @ledger.save
    else
      flash.now[:error] = "Dont act smart."
    end
    respond_to do |format|
      if @success
        format.html { redirect_to @ledger, notice: 'Ledger was successfully created.' }
        format.json { render :show, status: :created, location: @ledger }
      else
        format.html { render :new }
        format.json { render json: @ledger.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ledgers/1
  # PATCH/PUT /ledgers/1.json
  def update
    respond_to do |format|
      if @ledger.update(ledger_params)
        format.html { redirect_to @ledger, notice: 'Ledger was successfully updated.' }
        format.json { render :show, status: :ok, location: @ledger }
      else
        format.html { render :edit }
        format.json { render json: @ledger.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ledgers/1
  # DELETE /ledgers/1.json
  def destroy
    @ledger.destroy
    respond_to do |format|
      format.html { redirect_to ledgers_url, notice: 'Ledger was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ledger
      @ledger = Ledger.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def ledger_params
      params.require(:ledger).permit(:name, :opening_blnc, :group_id, :opening_blnc_type)
    end
end
