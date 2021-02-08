class VisitorBillsController < VisitorsController
  def index
    @filterrific = initialize_filterrific(
        Bill,
        params[:filterrific],
        persistence_id: false
    ) or return

    @bills = @filterrific.find.order(bill_number: :asc).includes(:client_account).page(params[:page]).per(5).decorate
  end
end