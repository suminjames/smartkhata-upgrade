class CreateBankPaymentLetterService
  include ApplicationHelper


  def initialize(params)
    @sales_settlement = params[:sales_settlement]
    @bills = params[:bills]
  end

  def process
    fy_code = get_fy_code

    grouped_share_transaction = Hash.new
    # group the share transactions and get the sum of net amount
    @bills.each do |bill|

    end

  end

  def group_transaction_by_client(share_transactions)

  end


end
