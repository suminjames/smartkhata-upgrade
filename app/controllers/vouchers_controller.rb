class VouchersController < ApplicationController
  before_action :set_voucher, only: [:show, :edit, :update, :destroy]

  # GET /vouchers
  # GET /vouchers.json
  def index
    @vouchers = Voucher.all
  end

  # GET /vouchers/1
  # GET /vouchers/1.json
  def show
  end

  # GET /vouchers/new
  def new
    @voucher = Voucher.new
    @voucher.particulars = [Particular.new]
  end

  # GET /vouchers/1/edit
  def edit
  end

  # POST /vouchers
  # POST /vouchers.json
  def create
    @voucher = Voucher.new(voucher_params)
    @cal = NepaliCalendar::Calendar.new

    bs_string_arr =  @voucher.date_bs.to_s.split(/-/)
    @voucher.date = @cal.bs_to_ad(bs_string_arr[0],bs_string_arr[1], bs_string_arr[2])
    @success = false
    @has_zero = false
    @net_blnc = 0;

    if @voucher.particulars.length > 1
      # check if debit equal credit or amount is not zero
      
      @voucher.particulars.each do |particular|
        @has_zero = true if particular.amnt == 0
        particular.trn_type.to_i == Particular.trans_types['Dr'] ? @net_blnc + particular.amnt : @net_blnc + particular.amnt
      end
      if @net_blnc == 0 && @has_zero == false
        Voucher.transaction do 
          @voucher.particulars.each do |particular|
            ledger = Ledger.find(particular.ledger_id)
            closing_blnc = ledger.closing_blnc
            ledger.closing_blnc = ( particular.trn_type.to_i == Particular.trans_types['Dr'] ? closing_blnc + particular.amnt : closing_blnc - particular.amnt)
            particular.opening_blnc = closing_blnc
            particular.running_blnc = ledger.closing_blnc
            ledger.save
          end
          @success = true if @voucher.save 
        end
      else
        @voucher.errors[:base] << "This person is invalid because ..."
      end
    else
      @voucher.errors[:particular] << "This person is invalid because ..."
    end
    


    # abort("Message goes here")
    respond_to do |format|
      if @success
        format.html { redirect_to @voucher, notice: 'Voucher was successfully created.' }
        format.json { render :show, status: :created, location: @voucher }
      else
        format.html { render :new, notice: 'Dont act smart.' }
        format.json { render json: @voucher.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /vouchers/1
  # PATCH/PUT /vouchers/1.json
  def update
    respond_to do |format|
      if @voucher.update(voucher_params)
        format.html { redirect_to @voucher, notice: 'Voucher was successfully updated.' }
        format.json { render :show, status: :ok, location: @voucher }
      else
        format.html { render :edit }
        format.json { render json: @voucher.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /vouchers/1
  # DELETE /vouchers/1.json
  def destroy
    @voucher.destroy
    respond_to do |format|
      format.html { redirect_to vouchers_url, notice: 'Voucher was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_voucher
      @voucher = Voucher.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def voucher_params
      params.require(:voucher).permit(:date_bs, :desc, particulars_attributes: [:ledger_id,:description, :amnt,:trn_type])
    end
end
