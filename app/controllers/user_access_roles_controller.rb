class UserAccessRolesController < ApplicationController
  before_action :set_user_access_role, only: [:show, :edit, :update, :destroy]

  before_action -> {authorize @user_access_role}, only: [:show, :edit, :update, :destroy]
  before_action -> {authorize UserAccessRole}, only: [:index, :new, :create]

  # GET /user_access_roles
  # GET /user_access_roles.json
  def index
    @user_access_roles = UserAccessRole.all
  end

  # GET /user_access_roles/1
  # GET /user_access_roles/1.json
  def show
    @menu_items = MenuItem.arrange
  end

  # GET /user_access_roles/new
  def new
    @user_access_role = UserAccessRole.new
    @menu_items = MenuItem.arrange
  end

  # GET /user_access_roles/1/edit
  def edit
    @menu_items = MenuItem.arrange

    # # get menu ids
    # menu_ids = []
    # menu_ids = params[:user_access_role][:menu_ids].map(&:to_i) if params[:user_access_role].present? && params[:user_access_role][:menu_ids].present?
    # ActiveRecord::Base.transaction do
    #   # delete previously set records
    #   # TODO(SUBAS) remove only the changed ones
    #   # create only the changed ones
    #   MenuPermission.delete_previous_permissions_for(@employee_account.user_id)
    #   menu_ids.each do |menu_id|
    #     MenuPermission.create!(user_id: @employee_account.user_id, menu_item_id: menu_id)
    #   end
    # end
  end

  # POST /user_access_roles
  # POST /user_access_roles.json
  def create
    @menu_items = MenuItem.arrange
    @user_access_role = UserAccessRole.new(user_access_role_params)



    respond_to do |format|
      if @user_access_role.save
        format.html { redirect_to @user_access_role, notice: 'User access role was successfully created.' }
        format.json { render :show, status: :created, location: @user_access_role }
      else
        format.html { render :new }
        format.json { render json: @user_access_role.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /user_access_roles/1
  # PATCH/PUT /user_access_roles/1.json
  def update
    respond_to do |format|
      if @user_access_role.update(user_access_role_params)
        format.html { redirect_to @user_access_role, notice: 'User access role was successfully updated.' }
        format.json { render :show, status: :ok, location: @user_access_role }
      else
        format.html { render :edit }
        format.json { render json: @user_access_role.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /user_access_roles/1
  # DELETE /user_access_roles/1.json
  def destroy
    @user_access_role.destroy
    respond_to do |format|
      format.html { redirect_to user_access_roles_url, notice: 'User access role was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user_access_role
      @user_access_role = UserAccessRole.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_access_role_params
      params.require(:user_access_role).permit(:role_type, :role_name, :description, :menu_item_ids => [])
    end
end
