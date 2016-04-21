class EmployeeClientAssociationsController < ApplicationController
  before_action :set_employee_client_association, only: [:show, :edit, :update, :destroy]

  # GET /employee_client_associations
  # GET /employee_client_associations.json
  def index
    @employee_client_associations = EmployeeClientAssociation.all
    @employees = EmployeeAccount.all
  end

  # GET /employee_client_associations/1
  # GET /employee_client_associations/1.json
  def show
  end

  # GET /employee_client_associations/new
  def new
    @employee_client_association = EmployeeClientAssociation.new
  end

  # GET /employee_client_associations/1/edit
  def edit
  end

  # POST /employee_client_associations
  # POST /employee_client_associations.json
  def create
    p 'FUck it @ Create!'
    @employee_client_association = EmployeeClientAssociation.new(employee_client_association_params)

    respond_to do |format|
      if @employee_client_association.save
        format.html { redirect_to @employee_client_association, notice: 'Employee client association was successfully created.' }
        format.json { render :show, status: :created, location: @employee_client_association }
      else
        format.html { render :new }
        format.json { render json: @employee_client_association.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /employee_client_associations/1
  # PATCH/PUT /employee_client_associations/1.json
  def update
    respond_to do |format|
      if @employee_client_association.update(employee_client_association_params)
        format.html { redirect_to @employee_client_association, notice: 'Employee client association was successfully updated.' }
        format.json { render :show, status: :ok, location: @employee_client_association }
      else
        format.html { render :edit }
        format.json { render json: @employee_client_association.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /employee_client_associations/1
  # DELETE /employee_client_associations/1.json
  def destroy
    @employee_client_association.destroy
    respond_to do |format|
      format.html { redirect_to employee_client_associations_url, notice: 'Employee client association was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_employee_client_association
      @employee_client_association = EmployeeClientAssociation.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def employee_client_association_params
      params.fetch(:employee_client_association, {})
    end
end
