class VisitorBillsController < VisitorsController
  def index
    @bills = Bill.all.page(params[:page] || 1).per(5).decorate
  end

  def search
    @client_account = ClientAccount.find_by(nepse_code: params[:q][:nepse].upcase) rescue nil
    @bills = @client_account.bills.page(params[:page] || 1).per(5).decorate if @client_account

    render 'search', layout: false
  end
end