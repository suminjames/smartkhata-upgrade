class IsinInfosController < ApplicationController
  before_action :set_isin_info, only: [:show, :edit, :update, :destroy]

  before_action :authorize_isin_class, only: [:index, :new, :create]
  before_action :authorize_isin_record, only: [:show, :edit, :update, :destroy]

  # GET /isin_infos
  # GET /isin_infos.json
  def index
    @isin_infos = IsinInfo.all.page(params[:page]).per(20).order(:isin)
  end

  # GET /isin_infos/1
  # GET /isin_infos/1.json
  def show
  end

  # GET /isin_infos/new
  def new
    @isin_info = IsinInfo.new
  end

  # GET /isin_infos/1/edit
  def edit
  end

  # POST /isin_infos
  # POST /isin_infos.json
  def create
    @isin_info = IsinInfo.new(isin_info_params)

    respond_to do |format|
      if @isin_info.save
        format.html { redirect_to @isin_info, notice: 'Listed company was successfully created.' }
        format.json { render :show, status: :created, location: @isin_info }
      else
        format.html { render :new }
        format.json { render json: @isin_info.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /isin_infos/1
  # PATCH/PUT /isin_infos/1.json
  def update
    respond_to do |format|
      if @isin_info.update(isin_info_params)
        format.html { redirect_to @isin_info, notice: 'Listed company was successfully updated.' }
        format.json { render :show, status: :ok, location: @isin_info }
      else
        format.html { render :edit }
        format.json { render json: @isin_info.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /isin_infos/1
  # DELETE /isin_infos/1.json
  def destroy
    @isin_info.destroy
    respond_to do |format|
      format.html { redirect_to isin_infos_url, notice: 'Listed company was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_isin_info
      @isin_info = IsinInfo.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def isin_info_params
      params.require(:isin_info).permit(:company, :isin, :sector)
    end

    def authorize_isin_class
      authorize IsinInfo
    end

    def authorize_isin_record
      authorize @isin_info
    end
end
