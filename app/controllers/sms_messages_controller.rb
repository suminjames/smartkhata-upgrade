class SmsMessagesController < ApplicationController
  before_action :set_sms_message, only: [:show, :edit, :update, :destroy]

  # GET /sms_messages
  # GET /sms_messages.json
  def index
    @sms_messages = SmsMessage.all
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
