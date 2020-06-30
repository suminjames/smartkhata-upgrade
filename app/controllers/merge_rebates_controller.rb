class MergeRebatesController < ApplicationController
  before_action :set_merge_rebate, only: [:show, :edit, :update, :destroy]
  before_action -> {authorize MergeRebate}, only: [:index, :new, :create]
  # GET /merge_rebates
  # GET /merge_rebates.json
  def index
    @merge_rebates = MergeRebate.all
  end

  # GET /merge_rebates/1
  # GET /merge_rebates/1.json
  def show
  end

  # GET /merge_rebates/new
  def new
    @merge_rebate = MergeRebate.new
  end

  # GET /merge_rebates/1/edit
  def edit
  end

  # POST /merge_rebates
  # POST /merge_rebates.json
  def create
    @merge_rebate = MergeRebate.new(merge_rebate_params)

    respond_to do |format|
      if @merge_rebate.save
        format.html { redirect_to @merge_rebate, notice: 'Merge rebate was successfully created.' }
        format.json { render :show, status: :created, location: @merge_rebate }
      else
        format.html { render :new }
        format.json { render json: @merge_rebate.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /merge_rebates/1
  # PATCH/PUT /merge_rebates/1.json
  def update
    respond_to do |format|
      if @merge_rebate.update(merge_rebate_params)
        format.html { redirect_to @merge_rebate, notice: 'Merge rebate was successfully updated.' }
        format.json { render :show, status: :ok, location: @merge_rebate }
      else
        format.html { render :edit }
        format.json { render json: @merge_rebate.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /merge_rebates/1
  # DELETE /merge_rebates/1.json
  def destroy
    @merge_rebate.destroy
    respond_to do |format|
      format.html { redirect_to merge_rebates_url, notice: 'Merge rebate was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_merge_rebate
      @merge_rebate = MergeRebate.find(params[:id])
      authorize(@merge_rebate)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def merge_rebate_params
      params.require(:merge_rebate).permit(:scrip, :rebate_start, :rebate_end)
    end
end
