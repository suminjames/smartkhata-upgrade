class Report::ThresholdTransactionsController < ApplicationController
	def index
		@transaction_date = params[:transaction_date]
		if parsable_date? @transaction_date
			date_ad = bs_to_ad(@transaction_date)
			@transactions_above_threshold = ShareTransaction.not_cancelled.find_by_date(date_ad).where("net_amount >= ?", 500000)
		else
			@transactions_above_threshold = ''
			respond_to do |format|
				format.html { render :index }
				flash.now[:error] = 'Invalid date'
				format.json { render json: flash.now[:error], status: :unprocessable_entity }
			end
		end
	end
end