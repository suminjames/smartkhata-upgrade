class Report::TrialBalanceController < ApplicationController
  before_action -> {authorize self}
  layout 'application_custom', only: [:index]

  def index
    @date = ad_to_bs_string(Date.today)
    if selected_fy_code != get_fy_code
      @date = ad_to_bs_string(fiscal_year_last_day(selected_fy_code))
    end

    @download_path_xlsx =  report_trial_balance_index_path(@ledger, params.permit(:format).merge({format: 'xlsx'}))

    @sort_by = ['name', 'closing_balance'].include?(params[:sort_by]) ? params[:sort_by] : 'name';
    _order = @sort_by == 'closing_balance' ? 'desc' : 'asc'

    if params[:search_by] == 'all'
      @balance = Group.trial_balance
      @balance_report = Hash.new

      @balance.each do |balance|
        modified_ledger_list = []

        branch_id = selected_branch_id
        fy_code = selected_fy_code

        ledger_ids = balance.descendent_ledgers.pluck(:id)

        if branch_id == 0
          b = LedgerBalance.includes(:ledger).where(branch_id: nil, fy_code: fy_code).where('opening_balance != 0 OR closing_balance != 0 OR ledger_balances.dr_amount != 0 OR ledger_balances.cr_amount != 0').where(ledgers: {id: ledger_ids}).order("#{@sort_by } #{_order}").as_json
        else
          b = LedgerBalance.includes(:ledger).where(branch_id: branch_id, fy_code: fy_code).where('opening_balance != 0 OR closing_balance != 0 OR ledger_balances.dr_amount != 0 OR ledger_balances.cr_amount != 0').where(ledgers: {id: ledger_ids}).order("#{@sort_by} #{_order}").as_json
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
        if is_valid_bs_date? date_bs
          @balance = Group.balance_sheet
          @balance_report = Hash.new
          date_ad = bs_to_ad(date_bs)
          @date = date_bs
          branch_id = selected_branch_id == 0 ? nil : selected_branch_id
          fy_code = selected_fy_code
          # index = 1
          @balance.each do |balance|
            ledger_ids = balance.descendent_ledgers.pluck(:id)
            # get ledger balances using ledger dailies
            ledger_balances = LedgerBalance.where(fy_code: fy_code, branch_id: branch_id, ledger_id: ledger_ids).joins("join ledgers on ledgers.id = ledger_balances.ledger_id").joins("inner join ledger_dailies on ledger_balances.ledger_id = ledger_dailies.ledger_id and ledger_dailies.fy_code = ledger_balances.fy_code and (ledger_dailies.branch_id = ledger_balances.branch_id OR (ledger_dailies.branch_id is NULL  and ledger_balances.branch_id is NULL)) AND ledger_dailies.date <= '#{date_ad}'").group("ledger_dailies.ledger_id").select("Max(opening_balance) as opening_balance, SUM(ledger_dailies.cr_amount) as cr_amount,  SUM(ledger_dailies.dr_amount) as dr_amount, max(ledger_balances.ledger_id) as ledger_id, max(name) as lname")

            modified_ledger_list = ledger_balances.map do |ledger_daily|
              ledger_daily[:closing_balance] = ledger_daily[:opening_balance] + ledger_daily[:dr_amount] - ledger_daily[:cr_amount]
              ledger_daily.as_json({ ledger_name: ledger_daily[:lname] })
            end


            ledgers_with_no_transactons = Ledger.where(id: ledger_ids, ledger_dailies: { id: nil }).joins("left outer join ledger_dailies on ledger_dailies.ledger_id = ledgers.id and ledger_dailies.fy_code = #{fy_code} and ledger_dailies.branch_id #{branch_id ? '= ' + branch_id.to_s : 'IS NULL'} AND ledger_dailies.date <= '#{date_ad}'").pluck(:id)

            lb = LedgerBalance.includes(:ledger).where(branch_id: branch_id, fy_code: fy_code).where('opening_balance != 0').where(ledgers: {id: ledgers_with_no_transactons}).as_json

            lb.each do |l|
              l["dr_amount"] = 0
              l["cr_amount"] = 0
              l["closing_balance"] = l["opening_balance"]
            end
            modified_ledger_list += lb

            @balance_report[balance.name] = modified_ledger_list.sort_by { |hsh| hsh["closing_balance"].to_f }.reverse
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
