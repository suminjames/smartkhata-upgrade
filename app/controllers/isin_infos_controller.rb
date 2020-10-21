class IsinInfosController < ApplicationController
  before_action :set_isin_info, only: %i[show edit update destroy]

  before_action :authorize_isin_class, only: %i[index new create combobox_ajax_filter]
  before_action :authorize_isin_record, only: %i[show edit update destroy]

  # GET /isin_infos
  # GET /isin_infos.json
  def index
    @filterrific = initialize_filterrific(
      IsinInfo,
      params[:filterrific],
      select_options: {
        by_isin_info_id: IsinInfo.options_for_isin_info_select(params[:filterrific]),
        by_sector: IsinInfo.options_for_sector_select,
        by_isin: IsinInfo.options_for_isin_select
      },
      persistence_id: false
    ) or return
    @isin_infos = @filterrific.find.page(params[:page]).per(20).order(:isin)
  rescue RuntimeError => e
    puts "Had to reset filterrific params: #{e.message}"
    respond_to do |format|
      flash.now[:error] = e.message.to_s
      format.html { render :index }
      format.json { render json: flash.now[:error], status: :unprocessable_entity }
    end

      # Recover from invalid param sets, e.g., when a filter refers to the
      # database id of a record that doesn’t exist any more.
      # In this case we reset filterrific and discard all filter params.
  rescue ActiveRecord::RecordNotFound => e
    # There is an issue with the persisted param_set. Reset it.
    puts "Had to reset filterrific params: #{e.message}"
    redirect_to(reset_filterrific_url(format: :html)) and return
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

  def combobox_ajax_filter
    search_term = params[:q]
    isin_infos = []
    # 3 is the minimum search_term length to invoke find_similar_to_name
    isin_infos = IsinInfo.find_similar_to_term(search_term, params[:full_record]) if search_term && search_term.length >= 3
    respond_to do |format|
      format.json { render json: isin_infos, status: :ok }
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
