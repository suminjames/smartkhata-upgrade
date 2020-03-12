class CloseoutsController < ApplicationController
  before_action :set_closeout, only: [:show, :edit, :update, :destroy]

  before_action -> {authorize @closeout}, only: [:show, :edit, :update, :destroy]
  before_action -> {authorize Closeout}, only: [:index, :new, :create]

  # GET /closeouts
  # GET /closeouts.json
  def index
    @closeouts = Closeout.all
  end

  # GET /closeouts/1
  # GET /closeouts/1.json
  def show
  end

  # GET /closeouts/new
  def new
    @closeout = Closeout.new
  end

  # GET /closeouts/1/edit
  def edit
  end

  # POST /closeouts
  # POST /closeouts.json
  def create
    @closeout = Closeout.new(closeout_params)

    respond_to do |format|
      if @closeout.save
        format.html { redirect_to @closeout, notice: 'Closeout was successfully created.' }
        format.json { render :show, status: :created, location: @closeout }
      else
        format.html { render :new }
        format.json { render json: @closeout.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /closeouts/1
  # PATCH/PUT /closeouts/1.json
  def update
    respond_to do |format|
      if @closeout.update(closeout_params)
        format.html { redirect_to @closeout, notice: 'Closeout was successfully updated.' }
        format.json { render :show, status: :ok, location: @closeout }
      else
        format.html { render :edit }
        format.json { render json: @closeout.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /closeouts/1
  # DELETE /closeouts/1.json
  def destroy
    @closeout.destroy
    respond_to do |format|
      format.html { redirect_to closeouts_url, notice: 'Closeout was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_closeout
    @closeout = Closeout.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def closeout_params
    permitted_params = params.fetch(:closeout, {})
    with_branch_user_params(permitted_params)
  end
end
