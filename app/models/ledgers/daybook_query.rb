class Ledgers::DaybookQuery
  attr_reader :error_message, :selected_branch_id, :selected_fy_code
  include CustomDateModule

  def initialize(params, selected_branch_id, selected_fy_code, rel = Ledger)
    @rel = rel
    @particulars = ''
    @params = params
    @total_credit = 0.0
    @total_debit = 0.0
    @error_message = ''
    @closing_balance_sorted = nil
    @opening_balance_sorted = nil
    @daybook_ledger_ids = Ledger.daybook_ledgers.pluck(:id)
    @selected_branch_id = selected_branch_id
    @selected_fy_code = selected_fy_code
  end

  def ledger_with_particulars
    page = @params[:page].to_i - 1 if @params[:page].present? || 0
    opening_balance = 0
    Ledger.daybook_ledgers.each do |ledger|
      opening_balance += ledger.opening_balance
    end

    if @params[:search_by] == "all"
      # for pages greater than 0, we need carryover balance
      opening_balance =  opening_balance_for_page(opening_balance, page) if page.positive?
      @particulars = get_particulars(@params[:page])
    elsif @params[:search_by] && @params[:search_term]
      search_by = @params[:search_by]
      search_term = @params[:search_term]
      case search_by
        when 'date'
          # The dates being entered are assumed to be BS dates, not AD dates
          date_bs = search_term['date']
          # OPTIMIZE: Notify front-end of the particular date(s) invalidity
          if parsable_date?(date_bs)
            date_ad = bs_to_ad(date_bs)

            # get the ordered particulars
            @particulars = get_particulars(@params[:page], 20, date_ad, date_ad)

            # sum of total credit and debit amount
            @total_credit = Particular.find_by_ledger_ids(@daybook_ledger_ids).complete.find_by_date(date_ad).cr.sum(:amount)
            @total_debit = Particular.find_by_ledger_ids(@daybook_ledger_ids).complete.find_by_date(date_ad).dr.sum(:amount)

            # get the closing balance from the previous day of date_from
            previous_day_ledger_dailies = LedgerDaily.where(ledger_id: @daybook_ledger_ids).by_branch_fy_code_default.where('date < ?', date_ad).order('date DESC')
            previous_day_balance = previous_day_ledger_dailies.present? ? LedgerDaily.closing_balance_of_ledger_dailies(previous_day_ledger_dailies.pluck(:id)) : 0.0

            # get the last day ledger daily balance for the query date
            last_day_ledger_dailies = LedgerDaily.where(ledger_id: @daybook_ledger_ids).by_branch_fy_code_default.where('date <= ?', date_ad).order('date DESC')
            last_day_balance = last_day_ledger_dailies.present? ? LedgerDaily.closing_balance_of_ledger_dailies(last_day_ledger_dailies.pluck(:id)) : 0.0

            @opening_balance_sorted = previous_day_balance
            @closing_balance_sorted = last_day_balance

            # make the adjustment for the carryover balance, and adjustment for the pagination and running total
            opening_balance += previous_day_balance
            opening_balance =  opening_balance_for_page(opening_balance, page, date_ad, date_ad) if page.positive?

          else
            @error_message = "Invalid Date"
          end
        when 'date_range'
          # The dates being entered are assumed to be BS dates, not AD dates
          date_from_bs = search_term['date_from']
          date_to_bs = search_term['date_to']
          # OPTIMIZE: Notify front-end of the particular date(s) invalidity
          if parsable_date?(date_from_bs) && parsable_date?(date_to_bs)
            date_from_ad = bs_to_ad(date_from_bs)
            date_to_ad = bs_to_ad(date_to_bs)

            # get the ordered particulars
            @particulars = get_particulars(@params[:page], 20, date_from_ad, date_to_ad)

            # sum of total credit and debit amount
            @total_credit = Particular.find_by_ledger_ids(@daybook_ledger_ids).complete.find_by_date_range(date_from_ad, date_to_ad).cr.sum(:amount)
            @total_debit = Particular.find_by_ledger_ids(@daybook_ledger_ids).complete.find_by_date_range(date_from_ad, date_to_ad).dr.sum(:amount)

            # get the closing balance from the previous day of date_from
            previous_day_ledger_dailies = LedgerDaily.where(ledger_id: @daybook_ledger_ids).by_branch_fy_code_default.where('date < ?', date_from_ad).order('date DESC')
            previous_day_balance = previous_day_ledger_dailies.present? ? LedgerDaily.closing_balance_of_ledger_dailies(previous_day_ledger_dailies.pluck(:id)) : 0.0

            # get the last day ledger daily balance for the query date
            last_day_balance = LedgerDaily.sum_of_closing_balance_of_ledger_dailies_for_ledgers(@daybook_ledger_ids, date_to_ad, selected_fy_code, selected_branch_id)

            @opening_balance_sorted = previous_day_balance
            @closing_balance_sorted = last_day_balance

            # make the adjustment for the carryover balance, and adjustment for the pagination and running total
            opening_balance += previous_day_balance
            opening_balance =  opening_balance_for_page(opening_balance, page, date_from_ad, date_to_ad) if page.positive?

          else
            @error_message = "Invalid Date"
          end
      end
    elsif !@params[:search_by]
      # for pages greater than we need carryover balance
      opening_balance = opening_balance_for_page(opening_balance, page) if page.positive?
      @particulars = get_particulars(@params[:page])
    end

    # grab the particulars with running total
    @particulars = Particular.with_running_total(@particulars, opening_balance) if @particulars.present?
    [@particulars, @total_credit, @total_debit, @closing_balance_sorted, @opening_balance_sorted]
  end

  #
  # get the particulars based on conditions
  #
  def get_particulars(page, limit = 20, date_from_ad = nil, date_to_ad = nil)
    if date_from_ad.present? && date_to_ad.present?
      Particular.find_by_ledger_ids(@daybook_ledger_ids).complete.find_by_date_range(date_from_ad, date_to_ad).order('transaction_date ASC', 'created_at ASC').page(page).per(limit)
    else
      Particular.find_by_ledger_ids(@daybook_ledger_ids).complete.order('transaction_date ASC', 'created_at ASC').page(page).per(limit)
    end
  end

  #
  # get the carryover balance for the current page except 0
  #
  def opening_balance_for_page(opening_balance, page, date_from_ad = nil, date_to_ad = nil)
    # raw sql can be potentially dangerous and memory leakage point
    # need to make sure this has proper binding
    daybook_ledger_ids_str = @daybook_ledger_ids * ","
    query = if date_from_ad.present? && date_to_ad.present?
              "SELECT SUM(subquery.amount) FROM (SELECT ( CASE WHEN transaction_type = 0 THEN amount ELSE amount * -1 END ) as amount FROM particulars WHERE ledger_id IN (#{daybook_ledger_ids_str}) AND particular_status = 1 AND transaction_date BETWEEN '#{date_from_ad}' AND '#{date_to_ad}' ORDER BY transaction_date ASC, created_at ASC LIMIT #{20 * page}) AS subquery;"
            else
              "SELECT SUM(subquery.amount) FROM (SELECT ( CASE WHEN transaction_type = 0 THEN amount ELSE amount * -1 END ) as amount FROM particulars WHERE ledger_id IN (#{daybook_ledger_ids_str}) AND particular_status = 1 ORDER BY transaction_date ASC, created_at ASC LIMIT #{20 * page}) AS subquery;"
            end
    opening_balance += ActiveRecord::Base.connection.execute(query).getvalue(0, 0).to_f
    opening_balance
  end
end
