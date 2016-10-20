class Report::TrialBalanceController < ApplicationController
  before_action -> {authorize self}
  layout 'application_custom', only: [:index]

  def index
    @download_path_xlsx =  report_trial_balance_index_path(@ledger, {format:'xlsx'}.merge(params))

    if params[:search_by] == 'all'
      @balance = Group.trial_balance
      @balance_report = Hash.new

      @balance.each do |balance|
        modified_ledger_list = []
        @balance_report[balance.name] = balance.descendent_ledgers
        b = balance.descendent_ledgers
        b.each do |ledger|
          ledger.opening_balance_trial = ledger.opening_balance
          ledger.closing_balance_trial = ledger.closing_balance
          ledger.cr_amount_trial = ledger.cr_amount
          ledger.dr_amount_trial = ledger.dr_amount
          modified_ledger_list << ledger
        end
        @balance_report[balance.name] = modified_ledger_list
      end

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
                if ledger.ledger_dailies.by_branch_fy_code.where('date <= ?',date_ad).count > 0

                  # sum of total credit and debit amount
                  total_credit = ledger.ledger_dailies.by_branch_fy_code.where('date <= ?',date_ad).sum(:cr_amount)
                  total_debit = ledger.ledger_dailies.by_branch_fy_code.where('date <= ?',date_ad).sum(:dr_amount)
                  # get the opening balance from the first day
                  first_day_ledger_daily = ledger.ledger_dailies.by_branch_fy_code.where('date <= ?',date_ad).order('date ASC').first
                  first_day_opening_balance = first_day_ledger_daily.present? ? first_day_ledger_daily.opening_balance : 0.0

                  # get the closing balance from last day
                  last_day_ledger_daily =  ledger.ledger_dailies.by_branch_fy_code.where('date <= ?', date_ad).order('date DESC').first
                  last_day_balance = last_day_ledger_daily.present? ? last_day_ledger_daily.closing_balance : 0.0

                  ledger.opening_balance_trial = first_day_opening_balance
                  ledger.closing_balance_trial = last_day_balance
                  ledger.cr_amount_trial = total_credit
                  ledger.dr_amount_trial = total_debit
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

    if params[:format] == 'xlsx'
      report = Reports::Excelsheet::TrialBalanceReport.new(@balance_report, params, current_tenant)
      # if report.generated_successfully?
      #   # send_file(report.path, type: report.type)
      #   send_data(report.file, type: report.type, filename: report.filename)
      #   report.clear
      # else
      #   # This should be ideally an ajax notification!
      #   redirect_to ledgers_path, flash: { error: report.error }
      # end
      return
    end

  end
end
