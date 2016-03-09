class ChequeEntriesController < ApplicationController
  before_action :set_cheque_entry, only: [:show, :edit, :update, :destroy]

  # GET /cheque_entries
  # GET /cheque_entries.json
  def index
    @cheque_entries = ChequeEntry.all
  end

  # GET /cheque_entries/1
  # GET /cheque_entries/1.json
  def show
  end

  # GET /cheque_entries/new
  def new
    @cheque_entry = ChequeEntry.new
  end

  # GET /cheque_entries/1/edit
  def edit
  end

  # POST /cheque_entries
  # POST /cheque_entries.json
  def create
    @cheque_entry = ChequeEntry.new(cheque_entry_params)

    respond_to do |format|
      if @cheque_entry.save
        format.html { redirect_to @cheque_entry, notice: 'Cheque entry was successfully created.' }
        format.json { render :show, status: :created, location: @cheque_entry }
      else
        format.html { render :new }
        format.json { render json: @cheque_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /cheque_entries/1
  # PATCH/PUT /cheque_entries/1.json
  def update
    respond_to do |format|
      if @cheque_entry.update(cheque_entry_params)
        format.html { redirect_to @cheque_entry, notice: 'Cheque entry was successfully updated.' }
        format.json { render :show, status: :ok, location: @cheque_entry }
      else
        format.html { render :edit }
        format.json { render json: @cheque_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cheque_entries/1
  # DELETE /cheque_entries/1.json
  def destroy
    @cheque_entry.destroy
    respond_to do |format|
      format.html { redirect_to cheque_entries_url, notice: 'Cheque entry was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cheque_entry
      @cheque_entry = ChequeEntry.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def cheque_entry_params
      params.fetch(:cheque_entry, {})
    end
end
