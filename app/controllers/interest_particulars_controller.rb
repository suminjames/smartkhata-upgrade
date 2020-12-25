class InterestParticularsController < ApplicationController
  before_action -> { authorize InterestParticular }, only: [:index]
  
  def index
    if current_user.client? &&
      !current_user.belongs_to_client_account(params.dig(:filterrific, :by_client_id).to_i)
      user_not_authorized and return
    end
    
    @filterrific = initialize_filterrific(
      InterestParticular,
      params[:filterrific],
      select_options: {
        by_client_id: ClientAccount.options_for_client_select(params[:filterrific]),
        by_interest_type: InterestParticular.option_for_interest_type_select
      },
      persistence_id: false
    ) or return
    
    @interest_particulars = @filterrific.find.order(id: :asc).page(params[:page]).per(20).decorate

    respond_to do |format|
      format.html
      format.js
    end
  
  rescue ActiveRecord::RecordNotFound => e
    puts "Had to reset filterrific params: #{ e.message }"
    redirect_to(reset_filterrific_url(format: :html)) and return
  end
end
