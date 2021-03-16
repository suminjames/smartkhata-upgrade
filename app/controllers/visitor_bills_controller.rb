class VisitorBillsController < VisitorsController
  def index
    @filterrific = initialize_filterrific(
        Bill.requiring_receive_desc,
        params[:filterrific],
        persistence_id: false
    ) or return

    @bills = @filterrific.find.includes(:client_account).limit(5).decorate
  end
end
