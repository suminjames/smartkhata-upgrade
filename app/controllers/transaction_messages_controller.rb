class TransactionMessagesController < ApplicationController
  before_action :set_transaction_message, only: [:show, :edit, :update, :destroy]

  # GET /transaction_messages
  # GET /transaction_messages.json
  def index
    @transaction_messages = TransactionMessage.all
  end

  # GET /transaction_messages/1
  # GET /transaction_messages/1.json
  def show
  end

  # GET /transaction_messages/new
  def new
    @transaction_message = TransactionMessage.new
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
