class Ledgers::CashbookQuery
  attr_reader :error_message, :selected_branch_id, :selected_fy_code
  include CustomDateModule

  def initialize(params,selected_fy_code, selected_branch_id, rel = Ledger)
    @rel = rel
    @particulars = ''
    @params = params
    @total_credit = 0.0
    @total_debit = 0.0
    @error_message = ''
    @closing_balance_sorted = nil
    @opening_balance_sorted = nil
    @cashbook_ledger_ids = Ledger.cashbook_ledgers.pluck(:id)
    @selected_fy_code = selected_fy_code
    @selected_branch_id = selected_branch_id
  end

  def ledger_with_particulars(no_pagination = false)
    page = @params[:page].to_i - 1 if @params[:page].present? || 0
    # no pagination is required for xls/pdf file generation
    if no_pagination
      page = 0
    end

    opening_balance = 0
    Ledger.cashbook_ledgers.each do |ledger|
      opening_balance += ledger.opening_balance
    end

    if @params[:search_by] == "all"
      date_from_ad = Date.new(2000)
      date_to_ad = Date.today
      # for pages greater than 0, we need carryover balance
      opening_balance =  opening_balance_for_page(opening_balance, page) if  page > 0
      @particulars = get_particulars(@params[:page], 20, nil, nil, no_pagination)

      # sum of total credit and debit amount
      @total_credit = Particular.find_by_ledger_ids(@cashbook_ledger_ids).complete.find_by_date_range(date_from_ad, date_to_ad).cr.sum(:amount)
      @total_debit = Particular.find_by_ledger_ids(@cashbook_ledger_ids).complete.find_by_date_range(date_from_ad, date_to_ad).dr.sum(:amount)

      # get the closing balance from the previous day of date_from
      previous_day_balance = LedgerDaily.sum_of_closing_balance_of_ledger_dailies_for_ledgers(@cashbook_ledger_ids, date_from_ad - 1, selected_fy_code, selected_branch_id )


      # get the last day ledger daily balance for the query date
      last_day_balance = LedgerDaily.sum_of_closing_balance_of_ledger_dailies_for_ledgers(@cashbook_ledger_ids, date_to_ad, selected_fy_code, selected_branch_id)

      @opening_balance_sorted = previous_day_balance
      @closing_balance_sorted = last_day_balance

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
            @particulars = get_particulars(@params[:page], 20, date_ad, date_ad, no_pagination)

            # sum of total credit and debit amount
            @total_credit = Particular.find_by_ledger_ids(@cashbook_ledger_ids).complete.find_by_date(date_ad).cr.sum(:amount)
            @total_debit = Particular.find_by_ledger_ids(@cashbook_ledger_ids).complete.find_by_date(date_ad).dr.sum(:amount)

            # get the closing balance from the previous day of date_from
            previous_day_balance = LedgerDaily.sum_of_closing_balance_of_ledger_dailies_for_ledgers(@cashbook_ledger_ids, date_ad - 1, selected_fy_code, selected_branch_id )


            # get the last day ledger daily balance for the query date
            last_day_balance = LedgerDaily.sum_of_closing_balance_of_ledger_dailies_for_ledgers(@cashbook_ledger_ids, date_ad, selected_fy_code, selected_branch_id)

            @opening_balance_sorted = previous_day_balance
            @closing_balance_sorted = last_day_balance

            # make the adjustment for the carryover balance, and adjustment for the pagination and running total
            opening_balance += previous_day_balance
            opening_balance =  opening_balance_for_page(opening_balance, page, date_ad, date_ad) if  page > 0

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
            @particulars = get_particulars(@params[:page], 20, date_from_ad, date_to_ad, no_pagination)

            # sum of total credit and debit amount
            @total_credit = Particular.find_by_ledger_ids(@cashbook_ledger_ids).complete.find_by_date_range(date_from_ad, date_to_ad).cr.sum(:amount)
            @total_debit = Particular.find_by_ledger_ids(@cashbook_ledger_ids).complete.find_by_date_range(date_from_ad, date_to_ad).dr.sum(:amount)

            # get the closing balance from the previous day of date_from
            previous_day_balance = LedgerDaily.sum_of_closing_balance_of_ledger_dailies_for_ledgers(@cashbook_ledger_ids, date_from_ad - 1, selected_fy_code, selected_branch_id )

            # get the last day ledger daily balance for the query date
            last_day_balance = LedgerDaily.sum_of_closing_balance_of_ledger_dailies_for_ledgers(@cashbook_ledger_ids, date_to_ad, selected_fy_code, selected_branch_id)

            @opening_balance_sorted = previous_day_balance
            @closing_balance_sorted = last_day_balance

            # make the adjustment for the carryover balance, and adjustment for the pagination and running total
            opening_balance += previous_day_balance
            opening_balance =  opening_balance_for_page(opening_balance, page, date_from_ad, date_to_ad) if  page > 0

          else
            @error_message = "Invalid Date"
          end
      end
    elsif !@params[:search_by]
      # for pages greater than we need carryover balance
      opening_balance =  opening_balance_for_page(opening_balance, page) if  page > 0
      @particulars = get_particulars(@params[:page])
    end

    # grab the particulars with running total
    @particulars = Particular.with_running_total(@particulars, opening_balance) unless @particulars.blank?
    return @particulars, @total_credit, @total_debit, @closing_balance_sorted, @opening_balance_sorted
  end

  #
  # get the particulars based on conditions
  #
  def get_particulars(page, limit = 20, date_from_ad = nil, date_to_ad = nil, no_pagination = false)
    if no_pagination
      if date_from_ad.present? && date_to_ad.present?
        Particular.find_by_ledger_ids(@cashbook_ledger_ids).by_branch_fy_code.complete.find_by_date_range(date_from_ad, date_to_ad).order('transaction_date ASC','created_at ASC')
      else
        Particular.find_by_ledger_ids(@cashbook_ledger_ids).by_branch_fy_code.complete.order('transaction_date ASC','created_at ASC')
      end
    else
      if date_from_ad.present? && date_to_ad.present?
        Particular.find_by_ledger_ids(@cashbook_ledger_ids).by_branch_fy_code.complete.find_by_date_range(date_from_ad, date_to_ad).order('transaction_date ASC','created_at ASC').page(page).per(limit)
      else
        Particular.find_by_ledger_ids(@cashbook_ledger_ids).by_branch_fy_code.complete.order('transaction_date ASC','created_at ASC').page(page).per(limit)
      end
    end
  end

  #
  # get the carryover balance for the current page except 0
  #
  def opening_balance_for_page(opening_balance, page, date_from_ad = nil, date_to_ad = nil)
    # raw sql can be potentially dangerous and memory leakage point
    # need to make sure this has proper binding
    additional_condition = ""
    if selected_branch_id == 0
      additional_condition = "fy_code = #{selected_fy_code}"
    else
      additional_condition = "branch_id = #{selected_branch_id} AND fy_code = #{selected_fy_code}"
    end

    cashbook_ledger_ids_str = @cashbook_ledger_ids*","

    if date_from_ad.present? && date_to_ad.present?
      query = "SELECT SUM(subquery.amount) FROM (SELECT ( CASE WHEN transaction_type = 0 THEN amount ELSE amount * -1 END ) as amount FROM particulars WHERE ledger_id IN (#{cashbook_ledger_ids_str}) AND particular_status = 1 AND #{additional_condition} AND transaction_date BETWEEN '#{date_from_ad}' AND '#{date_to_ad}' ORDER BY transaction_date ASC, created_at ASC LIMIT #{20*page}) AS subquery;"
    else
      query = "SELECT SUM(subquery.amount) FROM (SELECT ( CASE WHEN transaction_type = 0 THEN amount ELSE amount * -1 END ) as amount FROM particulars WHERE ledger_id IN (#{cashbook_ledger_ids_str}) AND particular_status = 1 AND #{additional_condition} ORDER BY transaction_date ASC, created_at ASC LIMIT #{20*page}) AS subquery;"
    end
    opening_balance += ActiveRecord::Base.connection.execute(query).getvalue(0,0).to_f
    opening_balance
  end
end