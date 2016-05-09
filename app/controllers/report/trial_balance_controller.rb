class Report::TrialBalanceController < ApplicationController
  def index

    if params[:search_by] == 'all'
      @balance = Group.trial_balance
      @balance_report = Hash.new

      @balance.each do |balance|
        @balance_report[balance.name] = balance.descendent_ledgers
      end
    elsif params[:search_by] == 'lwd'
      date  = Time.now.to_date
      file_type = FileUpload::file_types[:floorsheet]
      fileupload = FileUpload.where(file_type: file_type).order("report_date desc").limit(1).first;
      if ( fileupload.present? )
        date = fileupload.report_date
      end

      respond_to do |format|
        format.html { redirect_to report_trial_balance_index_path(search_by: "date", search_term: ad_to_bs(date)) }
      end
      return
    elsif params[:search_by] && params[:search_term]
      search_by = params[:search_by]
      search_term = params[:search_term]
      case search_by
        when 'date'
          # The date being entered are assumed to be BS date, not AD date
          date_bs = search_term
          if parsable_date? date_bs
            @balance = Group.balance_sheet
            @balance_report = Hash.new
            date_ad = bs_to_ad(date_bs)

            @balance.each do |balance|
              modified_ledger_list = []
              b = balance.descendent_ledgers
              b.each do |ledger|
                day_ledger = ledger.ledger_dailies.where(date: date_ad)
                if day_ledger.length > 0
                  ledger.opening_blnc = day_ledger.first.opening_blnc
                  ledger.closing_blnc = day_ledger.last.closing_blnc
                    ledger.cr_amount = day_ledger.sum(:cr_amount)
                  ledger.dr_amount = day_ledger.sum(:dr_amount)
                  modified_ledger_list << ledger
                end
              end
              @balance_report[balance.name] = modified_ledger_list
            end
          else
            respond_to do |format|
              format.html { render :index }
              flash.now[:error] = 'Invalid date'
              format.json { render json: flash.now[:error], status: :unprocessable_entity }
            end
          end
      end
    end
  end
end
