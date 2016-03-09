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
    @particulars = @voucher.particulars
  end

  # GET /vouchers/new
  def new
    @voucher = Voucher.new
    @voucher.particulars = [Particular.new]

    @voucher_type = Voucher.voucher_types[params[:voucher_type]]
    case @voucher_type
    when Voucher.voucher_types[:sales]
      @ledger_list = BankAccount.all.uniq.collect(&:ledger)
      @ledger_list << Ledger.find_by(name: "Cash")
    end

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
    @has_error = false
    @error_message = ""
    @net_blnc = 0;

    if @voucher.particulars.length > 1
      # check if debit equal credit or amount is not zero

      @voucher.particulars.each do |particular|
        puts particular.ledger_id.nil?
        puts "testing"
        if particular.amnt == 0
          @has_error = true
          @error_message ="Dont act smart."
          break
        elsif particular.ledger_id.nil?
          @has_error = true
          @error_message ="Dont act smart. Particulars cant be empty"
          break
        end
        (particular.dr?) ? @net_blnc += particular.amnt : @net_blnc -= particular.amnt
      end

      if @voucher.particulars.length == 2 && !@has_error
        @voucher.particulars[0].name = Ledger.find(@voucher.particulars[1].ledger_id).name
        @voucher.particulars[1].name = Ledger.find(@voucher.particulars[0].ledger_id).name
      end

      # abort(@net_blnc.to_s)
      if @net_blnc == 0 && @has_error == false
        Voucher.transaction do
          @voucher.particulars.each do |particular|
            ledger = Ledger.find(particular.ledger_id)
            closing_blnc = ledger.closing_blnc
            ledger.closing_blnc = ( particular.dr?) ? closing_blnc + particular.amnt : closing_blnc - particular.amnt
            particular.opening_blnc = closing_blnc
            particular.running_blnc = ledger.closing_blnc
            ledger.save
          end
          @success = true if @voucher.save
        end
      else
        if @has_error
           flash.now[:error] = @error_message
        else
           flash.now[:error] = "Particulars should have balancing figures."
        end
      end
    else
      flash.now[:error] = "Particulars should be atleast 2"
    end



    # abort("Message goes here")
    respond_to do |format|
      if @success
        format.html { redirect_to @voucher, notice: 'Voucher was successfully created.' }
        format.json { render :show, status: :created, location: @voucher }
      else
        format.html { render :new }
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
      params.require(:voucher).permit(:date_bs, :desc, particulars_attributes: [:ledger_id,:description, :amnt,:transaction_type])
    end
end
