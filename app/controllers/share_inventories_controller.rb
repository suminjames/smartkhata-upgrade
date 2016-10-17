class ShareInventoriesController < ApplicationController
  before_action :set_share_inventory, only: [:show, :edit, :update, :destroy]

  before_action -> {authorize @share_inventory}, only: [:show, :edit, :update, :destroy]
  before_action -> {authorize ShareInventory}, only: [:index, :new, :create]

  # GET /share_inventories
  # GET /share_inventories.json
  def index
    @share_inventories = ShareInventory.all
  end

  # GET /share_inventories/1
  # GET /share_inventories/1.json
  def show
  end

  # GET /share_inventories/new
  def new
    @share_inventory = ShareInventory.new
  end

  # GET /share_inventories/1/edit
  def edit
  end

  # POST /share_inventories
  # POST /share_inventories.json
  def create
    @share_inventory = ShareInventory.new(share_inventory_params)

    respond_to do |format|
      if @share_inventory.save
        format.html { redirect_to @share_inventory, notice: 'Share inventory was successfully created.' }
        format.json { render :show, status: :created, location: @share_inventory }
      else
        format.html { render :new }
        format.json { render json: @share_inventory.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /share_inventories/1
  # PATCH/PUT /share_inventories/1.json
  def update
    respond_to do |format|
      if @share_inventory.update(share_inventory_params)
        format.html { redirect_to @share_inventory, notice: 'Share inventory was successfully updated.' }
        format.json { render :show, status: :ok, location: @share_inventory }
      else
        format.html { render :edit }
        format.json { render json: @share_inventory.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /share_inventories/1
  # DELETE /share_inventories/1.json
  def destroy
    @share_inventory.destroy
    respond_to do |format|
      format.html { redirect_to share_inventories_url, notice: 'Share inventory was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_share_inventory
    @share_inventory = ShareInventory.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def share_inventory_params
    params.fetch(:share_inventory, {})
  end
end
