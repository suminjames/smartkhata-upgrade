class VisitorBillsController < VisitorsController
  def index
    @filterrific = initialize_filterrific(
        Bill.find_not_settled,
        params[:filterrific],
        persistence_id: false
    ) or return

    @bills = @filterrific.find.order(created_at: :desc).includes(:client_account).limit(5).decorate
  end
end