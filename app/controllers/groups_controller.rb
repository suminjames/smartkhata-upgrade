class GroupsController < ApplicationController
  before_action :set_group, only: [:show, :edit, :update, :destroy]

  # GET /groups
  # GET /groups.json
  def index
    @groups = Group.all

    @balance = Group.balance_sheet
    @balance_dr = Hash.new
    @balance_cr = Hash.new
    @opening_balance_cr = 0;
    @opening_balance_dr = 0;
    @opening_balance_diff = 0;

    @balance.each do |balance|
      if balance.sub_report == Group.sub_reports['Assets']
        @balance_dr[balance.name] = balance.closing_blnc
        @opening_balance_dr += balance.closing_blnc
      end
      if balance.sub_report == Group.sub_reports['Liabilities']
        @balance_cr[balance.name] = balance.closing_blnc
        @opening_balance_cr += balance.closing_blnc
      end
       
      
    end
    @opening_balance_diff = @opening_balance_dr + @opening_balance_cr


    @balance = Group.pnl
    @profit = Hash.new
    @loss = Hash.new
    @amnt = 0
    @balance.each do |balance|
      if balance.sub_report == Group.sub_reports['Income']
        @profit[balance.name] = balance.closing_blnc 
        @amnt += balance.closing_blnc
      elsif balance.sub_report == Group.sub_reports['Expense']
        @loss[balance.name] = balance.closing_blnc     
        @amnt += balance.closing_blnc
      end
    end

  end

  # GET /groups/1
  # GET /groups/1.json
  def show
  end

  # GET /groups/new
  def new
    @group = Group.new
  end

  # GET /groups/1/edit
  def edit
  end

  # POST /groups
  # POST /groups.json
  def create
    @group = Group.new(group_params)

    respond_to do |format|
      if @group.save
        format.html { redirect_to @group, notice: 'Group was successfully created.' }
        format.json { render :show, status: :created, location: @group }
      else
        format.html { render :new }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /groups/1
  # PATCH/PUT /groups/1.json
  def update
    respond_to do |format|
      if @group.update(group_params)
        format.html { redirect_to @group, notice: 'Group was successfully updated.' }
        format.json { render :show, status: :ok, location: @group }
      else
        format.html { render :edit }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /groups/1
  # DELETE /groups/1.json
  def destroy
    @group.destroy
    respond_to do |format|
      format.html { redirect_to groups_url, notice: 'Group was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_group
      @group = Group.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def group_params
      params.fetch(:group, {})
    end
end
