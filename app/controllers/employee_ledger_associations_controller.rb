class EmployeeLedgerAssociationsController < ApplicationController
  before_action :set_employee_ledger_association, only: [:show, :edit, :update, :destroy]

  before_action -> {authorize @employee_ledger_association}, only: [:show, :edit, :update, :destroy]
  before_action -> {authorize EmployeeLedgerAssociation}, only: [:index, :new, :create]

  # GET /employee_ledger_associations
  # GET /employee_ledger_associations.json
  def index
    @employee_ledger_associations = EmployeeLedgerAssociation.all
  end

  # GET /employee_ledger_associations/1
  # GET /employee_ledger_associations/1.json
  def show
  end

  # GET /employee_ledger_associations/new
  def new
    @employee_ledger_association = EmployeeLedgerAssociation.new
  end

  # GET /employee_ledger_associations/1/edit
  def edit
  end

  # POST /employee_ledger_associations
  # POST /employee_ledger_associations.json
  def create
    @employee_ledger_association = EmployeeLedgerAssociation.new(employee_ledger_association_params)

    respond_to do |format|
      if @employee_ledger_association.save
        format.html { redirect_to @employee_ledger_association, notice: 'Employee ledger association was successfully created.' }
        format.json { render :show, status: :created, location: @employee_ledger_association }
      else
        format.html { render :new }
        format.json { render json: @employee_ledger_association.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /employee_ledger_associations/1
  # PATCH/PUT /employee_ledger_associations/1.json
  def update
    respond_to do |format|
      if @employee_ledger_association.update(employee_ledger_association_params)
        format.html { redirect_to @employee_ledger_association, notice: 'Employee ledger association was successfully updated.' }
        format.json { render :show, status: :ok, location: @employee_ledger_association }
      else
        format.html { render :edit }
        format.json { render json: @employee_ledger_association.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /employee_ledger_associations/1
  # DELETE /employee_ledger_associations/1.json
  def destroy
    @employee_ledger_association.destroy
    respond_to do |format|
      format.html { redirect_to employee_ledger_associations_url, notice: 'Employee ledger association was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_employee_ledger_association
    @employee_ledger_association = EmployeeLedgerAssociation.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def employee_ledger_association_params
    params.fetch(:employee_ledger_association, {})
  end
end
