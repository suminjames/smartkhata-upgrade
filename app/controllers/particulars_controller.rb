class ParticularsController < ApplicationController
  before_action :set_particular, only: [:show, :edit, :update, :destroy]

  # GET /particulars
  # GET /particulars.json
  def index
    @particulars = Particular.all
  end

  # GET /particulars/1
  # GET /particulars/1.json
  def show
  end

  # GET /particulars/new
  def new
    @particular = Particular.new
  end

  # GET /particulars/1/edit
  def edit
  end

  # POST /particulars
  # POST /particulars.json
  def create
    @particular = Particular.new(particular_params)

    respond_to do |format|
      if @particular.save
        format.html { redirect_to @particular, notice: 'Particular was successfully created.' }
        format.json { render :show, status: :created, location: @particular }
      else
        format.html { render :new }
        format.json { render json: @particular.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /particulars/1
  # PATCH/PUT /particulars/1.json
  def update
    respond_to do |format|
      if @particular.update(particular_params)
        format.html { redirect_to @particular, notice: 'Particular was successfully updated.' }
        format.json { render :show, status: :ok, location: @particular }
      else
        format.html { render :edit }
        format.json { render json: @particular.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /particulars/1
  # DELETE /particulars/1.json
  def destroy
    @particular.destroy
    respond_to do |format|
      format.html { redirect_to particulars_url, notice: 'Particular was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_particular
      @particular = Particular.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def particular_params
      params.fetch(:particular, {})
    end
end
