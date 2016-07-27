class TransactionMessagesController < ApplicationController
  before_action :set_transaction_message, only: [:show, :edit, :update, :destroy]

  # GET /transaction_messages
  # GET /transaction_messages.json
  def index
    @filterrific = initialize_filterrific(
        TransactionMessage,
        params[:filterrific],
        select_options: {
            by_client_id: TransactionMessage.options_for_client_select,
        },
        persistence_id: false
    ) or return
    items_per_page = params[:no_paginate] == 'true' ?  TransactionMessage.all.count : 20
    @transaction_messages = @filterrific.find.page(params[:page]).per(items_per_page).decorate

    respond_to do |format|
      format.html
      format.js
    end

      # Recover from 'invalid date' error in particular, among other RuntimeErrors.
      # OPTIMIZE(sarojk): Propagate particular error to specific field inputs in view.
  rescue RuntimeError => e
    puts "Had to reset filterrific params: #{ e.message }"
    respond_to do |format|
      flash.now[:error] = 'One of the search options provided is invalid.'
      format.html { render :index }
      format.json { render json: flash.now[:error], status: :unprocessable_entity }
    end

      # Recover from invalid param sets, e.g., when a filter refers to the
      # database id of a record that doesn’t exist any more.
      # In this case we reset filterrific and discard all filter params.
  rescue ActiveRecord::RecordNotFound => e
    # There is an issue with the persisted param_set. Reset it.
    puts "Had to reset filterrific params: #{ e.message }"
    redirect_to(reset_filterrific_url(format: :html)) and return
  end

  # GET /transaction_messages/1
  # GET /transaction_messages/1.json
  def show
    respond_to do |format|
      format.html
      format.js
      format.pdf do
        pdf = Pdf::PdfTransactionMessage.new(@transaction_message.transaction_date, @transaction_message.client_account, current_tenant)
        send_data pdf.render, filename: "TransactionMessage_#{@transaction_message.transaction_date}_#{@transaction_message.id}.pdf", type: 'application/pdf', disposition: "inline"
      end
    end
  end

  # GET /transaction_messages/new
  def new
    @transaction_message = TransactionMessage.new
  end

  def send_email
    transaction_message_ids = params[:transaction_message_ids] || []
    transaction_message_ids.each do | transaction_message_id |
      transaction_message = TransactionMessage.find_by(id: transaction_message_id)
      if transaction_message.can_email?
        UserMailer.delay(:retry => false).transaction_message_email(transaction_message.id, current_tenant.id)
      end
    end
    respond_to do |format|
      format.js
      format.json { render :json => { :success => "success", :status_code => "200" } }
    end
  end

  def send_sms
    transaction_message_ids = params[:transaction_message_ids] || []
    transaction_message_ids.each do | transaction_message_id |
      transaction_message = TransactionMessage.find_by(id: transaction_message_id)
      if transaction_message.can_sms?
        SmsMessage.send_bill_sms(transaction_message.id)
      end
    end
    respond_to do |format|
      format.js
      format.json { render :json => { :success => "success", :status_code => "200" } }
    end
  end

  def sent_status
    transaction_message_ids = params[:transaction_message_ids] || []
    @transaction_messages = []
    transaction_message_ids.each do | transaction_message_id |
      transaction_message = TransactionMessage.find(transaction_message_id)
      @transaction_messages << transaction_message
    end
    respond_to do |format|
      format.js
      format.json { render :json => @transaction_messages }
    end

  end

  # GET /transaction_messages/1/edit
  def edit
  end

  # POST /transaction_messages
  # POST /transaction_messages.json
  def create
    @transaction_message = TransactionMessage.new(transaction_message_params)

    respond_to do |format|
      if @transaction_message.save
        format.html { redirect_to @transaction_message, notice: 'Transaction message was successfully created.' }
        format.json { render :show, status: :created, location: @transaction_message }
      else
        format.html { render :new }
        format.json { render json: @transaction_message.errors, status: :unprocessable_entity }
      end
    end
  end


  def create_multiple
    transaction_date = params[:transaction_date]
    error_msg = "Error creating the transaction message"
    if transaction_date.present?
      create_sms_result = CreateSmsService.new(transaction_date: transaction_date, broker_code: current_tenant.broker_code)
      create_sms_result.create_by_floorsheet_date
      unless create_sms_result.error.present?
        redirect_to transaction_messages_path(:no_paginate => true, 'filterrific[by_date]': ad_to_bs(transaction_date)) and return
      end
      error_msg = create_sms_result.error
    end

    redirect_to transaction_messages_path, :flash => { :error => error_msg  }
  end

  # PATCH/PUT /transaction_messages/1
  # PATCH/PUT /transaction_messages/1.json
  def update
    respond_to do |format|
      if @transaction_message.update(transaction_message_params)
        format.html { redirect_to @transaction_message, notice: 'Transaction message was successfully updated.' }
        format.json { render :show, status: :ok, location: @transaction_message }
      else
        format.html { render :edit }
        format.json { render json: @transaction_message.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /transaction_messages/1
  # DELETE /transaction_messages/1.json
  def destroy
    @transaction_message.destroy
    respond_to do |format|
      format.html { redirect_to transaction_messages_url, notice: 'Transaction message was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_transaction_message
    @transaction_message = TransactionMessage.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def transaction_message_params
    params.require(:transaction_message).permit(:sms_message, :transaction_date, :sms_status, :email_status, :bill_id, :client_account_id)
  end
end
