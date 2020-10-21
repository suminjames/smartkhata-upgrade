class SmsMessagesController < ApplicationController
  before_action :set_sms_message, only: [:show, :edit, :update, :destroy]

  before_action -> {authorize @sms_message}, only: [:show, :edit, :update, :destroy]
  before_action -> {authorize SmsMessage}, only: [:index, :new, :create]

  # GET /sms_messages
  # GET /sms_messages.json
  def index
    @filterrific = initialize_filterrific(
      SmsMessage,
      params[:filterrific],
      select_options: {
        by_client_id: ClientAccount.options_for_client_select(params[:filterrific]),
        by_sms_message_type: SmsMessage.options_for_sms_message_type_select
      },
      persistence_id: false
    ) or return
    @sms_messages = @filterrific.find.includes(transaction_message: :client_account).page(params[:page]).per(20)

    respond_to do |format|
      format.html
      format.js
    end

  # Recover from 'invalid date' error in particular, among other RuntimeErrors.
  # OPTIMIZE(sarojk): Propagate particular error to specific field inputs in view.
  rescue RuntimeError => e
    puts "Had to reset filterrific params: #{e.message}"
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
    puts "Had to reset filterrific params: #{e.message}"
    redirect_to(reset_filterrific_url(format: :html)) and return
  end

  # GET /sms_messages/1
  # GET /sms_messages/1.json
  def show
end

  # GET /sms_messages/new
  def new
    @sms_message = SmsMessage.new
  end

  # GET /sms_messages/1/edit
  def edit
end

  # POST /sms_messages
  # POST /sms_messages.json
  def create
    @sms_message = SmsMessage.new(sms_message_params)

    respond_to do |format|
      if @sms_message.save
        format.html { redirect_to @sms_message, notice: 'Sms message was successfully created.' }
        format.json { render :show, status: :created, location: @sms_message }
      else
        format.html { render :new }
        format.json { render json: @sms_message.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /sms_messages/1
  # PATCH/PUT /sms_messages/1.json
  def update
    respond_to do |format|
      if @sms_message.update(sms_message_params)
        format.html { redirect_to @sms_message, notice: 'Sms message was successfully updated.' }
        format.json { render :show, status: :ok, location: @sms_message }
      else
        format.html { render :edit }
        format.json { render json: @sms_message.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sms_messages/1
  # DELETE /sms_messages/1.json
  def destroy
    @sms_message.destroy
    respond_to do |format|
      format.html { redirect_to sms_messages_url, notice: 'Sms message was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_sms_message
    @sms_message = SmsMessage.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def sms_message_params
    params.fetch(:sms_message, {})
  end
end
