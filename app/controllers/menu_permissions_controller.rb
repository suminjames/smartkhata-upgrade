class MenuPermissionsController < ApplicationController
  before_action :set_menu_permission, only: [:show, :edit, :update, :destroy]

  # GET /menu_permissions
  # GET /menu_permissions.json
  def index
    @menu_permissions = MenuPermission.all
  end

  # GET /menu_permissions/1
  # GET /menu_permissions/1.json
  def show
  end

  # GET /menu_permissions/new
  def new
    @menu_permission = MenuPermission.new
  end

  # GET /menu_permissions/1/edit
  def edit
  end

  # POST /menu_permissions
  # POST /menu_permissions.json
  def create
    @menu_permission = MenuPermission.new(menu_permission_params)

    respond_to do |format|
      if @menu_permission.save
        format.html { redirect_to @menu_permission, notice: 'Menu permission was successfully created.' }
        format.json { render :show, status: :created, location: @menu_permission }
      else
        format.html { render :new }
        format.json { render json: @menu_permission.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /menu_permissions/1
  # PATCH/PUT /menu_permissions/1.json
  def update
    respond_to do |format|
      if @menu_permission.update(menu_permission_params)
        format.html { redirect_to @menu_permission, notice: 'Menu permission was successfully updated.' }
        format.json { render :show, status: :ok, location: @menu_permission }
      else
        format.html { render :edit }
        format.json { render json: @menu_permission.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /menu_permissions/1
  # DELETE /menu_permissions/1.json
  def destroy
    @menu_permission.destroy
    respond_to do |format|
      format.html { redirect_to menu_permissions_url, notice: 'Menu permission was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_menu_permission
    @menu_permission = MenuPermission.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def menu_permission_params
    params.require(:menu_permission).permit(:menu_item_id, :user, :references)
  end
end
