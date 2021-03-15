class NchlReceiptsController < VisitorsController
  def create
    nchl_receipt = NchlReceipt.new(receipt_transaction_params)

    if nchl_receipt.save
      render json: nchl_receipt, methods: [:merchant_id, :app_id, :app_name,
                                           :transaction_id, :transaction_currency,
                                           :transaction_date, :reference_id,
                                           :remarks, :particular, :token]
    else
      render json: { error: 'cannot save nchl payment transaction record' }
    end
  end

  private

  def receipt_transaction_params
    params.permit(:amount, bill_ids: [])
  end
end