class EdisItemsController < ApplicationController
  before_action :set_edis_item, only: [:show, :edit, :update, :destroy]

  before_action -> { authorize EdisItem }

  # GET /edis_items
  # GET /edis_items.json
  def index
    @edis_items = EdisItem.all
    if params[:edis_report_id]
      @edis_items = @edis_items.where(edis_report_id: params[:edis_report_id])
    end
  end

  # GET /edis_items/1
  # GET /edis_items/1.json
  def show
    @edis_item.splitted_records = [ EdisItem.first ]
  end

  # GET /edis_items/new
  def new
    @edis_item = EdisItem.new
  end

  # GET /edis_items/1/edit
  def edit
  end


  def import
  #  copy contents from edis report new
    @edis_item_form = EdisItemForm.new
  end


  def process_import
    @edis_item_form = EdisItemForm.new(edis_item_form_params)
    if @edis_item_form.valid?
      @edis_item_form.import_file
      if @edis_item_form.errors.blank?
        redirect_to import_edis_items_path, notice: 'Successfully imported' and return
      end
    end
    render 'import'
  end

  # POST /edis_items
  # POST /edis_items.json
  def create
    @edis_item = EdisItem.new(edis_item_params)

    respond_to do |format|
      if @edis_item.save
        format.html { redirect_to @edis_item, notice: 'Edis item was successfully created.' }
        format.json { render :show, status: :created, location: @edis_item }
      else
        format.html { render :new }
        format.json { render json: @edis_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /edis_items/1
  # PATCH/PUT /edis_items/1.json
  def update
    respond_to do |format|
      if @edis_item.update(edis_item_params)
        format.html { redirect_to @edis_item, notice: 'Edis item was successfully updated.' }
        format.json { render :show, status: :ok, location: @edis_item }
      else
        format.html { render :edit }
        format.json { render json: @edis_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /edis_items/1
  # DELETE /edis_items/1.json
  def destroy
    @edis_item.destroy
    respond_to do |format|
      format.html { redirect_to edis_items_url, notice: 'Edis item was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_edis_item
      @edis_item = EdisItem.find(params[:id])
      authorize(@edis_item)
    end

  def edis_item_form_params
    params.require(:edis_item_form).permit( :file, :current_user_id, :skip_invalid_transactions)
  end

    # Never trust parameters from the scary internet, only allow the white list through.
    def edis_item_params
      params.require(:edis_item).permit(:id, :edis_report_id, :contract_number, :settlement_id, :settlement_date, :scrip, :boid, :client_code, :quantity, :wacc, :reason_code, split_options: [:wacc, :quantity, :reason_code])
    end
end
