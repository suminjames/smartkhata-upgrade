class Report::TrialBalanceController < ApplicationController
  before_action -> {authorize self}
  layout 'application_custom', only: [:index]

  def index_old
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
      if report.generated_successfully?
        send_data(report.file, type: report.type, filename: report.filename)
        report.clear
      else
        redirect_to report_trial_balance_index_path, flash: { error: report.error }
      end
    end

  end

  def index

    @download_path_xlsx =  report_trial_balance_index_path(@ledger, {format:'xlsx'}.merge(params))

    @sort_by = ['name', 'closing_balance'].include?(params[:sort_by]) ? params[:sort_by] : 'name';

    if params[:search_by] == 'all'
      @balance = Group.trial_balance
      @balance_report = Hash.new

      @balance.each do |balance|
        modified_ledger_list = []

        branch_id = UserSession.selected_branch_id
        fy_code = UserSession.selected_fy_code

        ledger_ids = balance.descendent_ledgers.pluck(:id)

        if branch_id == 0
          b = LedgerBalance.includes(:ledger).where(branch_id: nil, fy_code: fy_code).where('opening_balance != 0 OR closing_balance != 0 OR ledger_balances.dr_amount != 0 OR ledger_balances.cr_amount != 0').where(ledgers: {id: ledger_ids}).order("#{@sort_by } asc").as_json
        else
          b = LedgerBalance.includes(:ledger).where(branch_id: branch_id, fy_code: fy_code).where('opening_balance != 0 OR closing_balance != 0 OR ledger_balances.dr_amount != 0 OR ledger_balances.cr_amount != 0').where(ledgers: {id: ledger_ids}).order("#{@sort_by} asc").as_json
        end
        @balance_report[balance.name] = b
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

                  # new dummy ledger balance
                  # as we dont wont to messup with balances
                  ledger_daily = LedgerBalance.new
                  ledger_daily.opening_balance = first_day_opening_balance
                  ledger_daily.closing_balance = last_day_balance
                  ledger_daily.cr_amount = total_credit
                  ledger_daily.dr_amount = total_debit
                  modified_ledger_list << ledger_daily.as_json(ledger_name: ledger.name)
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
      if report.generated_successfully?
        send_data(report.file, type: report.type, filename: report.filename)
        report.clear
      else
        redirect_to report_trial_balance_index_path, flash: { error: report.error }
      end
    end
  end
end