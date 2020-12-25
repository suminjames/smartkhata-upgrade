class InterestParticularsController < ApplicationController
  before_action :set_interest_particular, only: [:show, :edit, :update, :destroy]

  before_action -> {authorize @interest_particular}, only: [:show, :edit, :update, :destroy]
  before_action -> {authorize InterestParticular}, only: [:index, :new, :create]

  # GET /interest_particulars
  # GET /interest_particulars.json
  def index
    @interest_particulars = InterestParticular.all
  end

  # GET /interest_particulars/1
  # GET /interest_particulars/1.json
  def show
  end

  # GET /interest_particulars/new
  def new
    @interest_particular = InterestParticular.new
  end

  # GET /interest_particulars/1/edit
  def edit
  end

  # POST /interest_particulars
  # POST /interest_particulars.json
  def create
    @interest_particular = InterestParticular.new(interest_particular_params)

    respond_to do |format|
      if @interest_particular.save
        format.html { redirect_to @interest_particular, notice: 'Interest particular was successfully created.' }
        format.json { render :show, status: :created, location: @interest_particular }
      else
        format.html { render :new }
        format.json { render json: @interest_particular.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /interest_particulars/1
  # PATCH/PUT /interest_particulars/1.json
  def update
    respond_to do |format|
      if @interest_particular.update(interest_particular_params)
        format.html { redirect_to @interest_particular, notice: 'Interest particular was successfully updated.' }
        format.json { render :show, status: :ok, location: @interest_particular }
      else
        format.html { render :edit }
        format.json { render json: @interest_particular.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /interest_particulars/1
  # DELETE /interest_particulars/1.json
  def destroy
    @interest_particular.destroy
    respond_to do |format|
      format.html { redirect_to interest_particulars_url, notice: 'Interest particular was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_interest_particular
      @interest_particular = InterestParticular.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def interest_particular_params
      params.fetch(:interest_particular, {})
    end
end
