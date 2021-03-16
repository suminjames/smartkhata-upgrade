class ReceiptTransactionsController < ApplicationController
  before_action -> {authorize ReceiptTransaction}, only: [:index, :combobox_ajax_filter]

  def index
    @filterrific = initialize_filterrific(
        ReceiptTransaction,
        params[:filterrific],
        select_options: {
            by_client_id: ClientAccount.options_for_client_select(params[:filterrific]),
        },
        persistence_id: false
    ) or return
    @receipt_transactions = @filterrific.find.includes(bills: :client_account).order(created_at: :desc)

    respond_to do |format|
      format.html
      format.js
    end
    rescue ActiveRecord::RecordNotFound => e
      # There is an issue with the persisted param_set. Reset it.
      puts "Had to reset filterrific params: #{e.message}"
      redirect_to(reset_filterrific_url(format: :html)) && return
  end

  def combobox_ajax_filter
    search_term = params[:q]
    selected_session_branch_id = selected_branch_id
    client_accounts = []
    # 3 is the minimum search_term length to invoke find_similar_to_name
    if search_term && search_term.length >= 3
      client_accounts = ClientAccount.find_similar_to_term(search_term, selected_session_branch_id)
    end
    respond_to do |format|
      format.json { render json: client_accounts, status: :ok }
    end
  end
end