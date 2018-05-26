# encoding: utf-8
# author: Subas Poudel
# email: dit.subas@gmail.com
class Ledgers::Query
  attr_reader :error_message, :branch_id, :fy_code, :opening_balance_calculated
  include CustomDateModule

  def initialize(params, ledger, branch_id=nil, fy_code=nil)
    @particulars = ''
    @params = params
    @ledger = ledger
    @total_credit = 0.0
    @total_debit = 0.0
    @error_message = ''
    @closing_balance_sorted = nil
    @opening_balance_sorted = nil
    @opening_balance_calculated = nil
    @branch_id = branch_id
    @fy_code = fy_code
  end

  def particular_size(no_pagination=true)
    return unless (@branch_id.present?  && @fy_code.present?)
    ledger_with_particulars(no_pagination, false)
    return @particulars.count
  end

  def particular_ids(no_pagination)
    ledger_with_particulars(no_pagination, false)
    return @particulars.pluck(:id)
  end

  def ledger_with_particulars(no_pagination = false, lazy_load=true)
    return unless (branch_id.present?  && fy_code.present?)
    page = @params[:page].to_i - 1 if @params[:page].present? || 0
    @opening_balance_calculated = @ledger.opening_balance if lazy_load

    # no pagination is required for xls/pdf file generation
    if no_pagination
      page = 0
    end

    if @params[:show] == "all"
      # for pages greater than we need carryover balance
      @opening_balance_calculated =  opening_balance_for_page(@opening_balance_calculated, page) if  page > 0 && lazy_load
      @particulars = get_particulars(@params[:page], 20, nil, nil, no_pagination, lazy_load)
    elsif @params[:search_by] && @params[:search_term]
      search_by = @params[:search_by]
      search_term = @params[:search_term]
      case search_by
      when 'date_range'
        # The dates being entered are assumed to be BS dates, not AD dates
        date_from_bs = search_term['date_from']
        date_to_bs = search_term['date_to']
        # OPTIMIZE: Notify front-end of the particular date(s) invalidity
        if is_valid_bs_date?(date_from_bs) && is_valid_bs_date?(date_to_bs)
          date_from_ad = bs_to_ad(date_from_bs)
          date_to_ad = bs_to_ad(date_to_bs)

          # get the ordered particulars
          @particulars = get_particulars(@params[:page], 20, date_from_ad, date_to_ad, no_pagination, lazy_load)

          if lazy_load
            # sum of total credit and debit amount
            @total_credit = @ledger.particulars.complete.by_branch_fy_code(branch_id, fy_code).find_by_date_range(date_from_ad, date_to_ad).cr.sum(:amount)
            @total_debit = @ledger.particulars.complete.by_branch_fy_code(branch_id, fy_code).find_by_date_range(date_from_ad, date_to_ad).dr.sum(:amount)

            # get the closing balance from the previous day of date_from
            first_ledger_daily = @ledger.ledger_dailies.by_branch_fy_code(branch_id, fy_code).where('date >= ?',date_from_ad).order('date ASC').first
            previous_day_balance = first_ledger_daily.present? ? first_ledger_daily.opening_balance : 0.0

            # get the last ledger daily balance for the query date
            last_day_ledger_daily =  @ledger.ledger_dailies.by_branch_fy_code(branch_id, fy_code).where('date <= ?',date_to_ad).order('date DESC').first
            last_day_balance = last_day_ledger_daily.present? ? last_day_ledger_daily.closing_balance : 0.0

            @closing_balance_sorted = last_day_balance
            @opening_balance_sorted = previous_day_balance

            # make the adjustment for the carryover balance
            # adjustment for the pagination and running total
            @opening_balance_calculated = previous_day_balance
            @opening_balance_calculated =  opening_balance_for_page(@opening_balance_calculated, page, date_from_ad, date_to_ad) if  page > 0
          end
        else
          @error_message = "Invalid Date"
        end
      end
    elsif !@params[:search_by]
      # for pages greater than we need carryover balance
      @opening_balance_calculated =  opening_balance_for_page(@opening_balance_calculated, page) if  page > 0 && lazy_load
      @particulars = get_particulars(@params[:page], 20, nil, nil, no_pagination, lazy_load)
    end
    return @particulars, @total_credit, @total_debit, @closing_balance_sorted, @opening_balance_sorted
  end

  def ledger_particulars_with_running_total(no_pagination = false)
    ledger_with_particulars(no_pagination)
    @particulars = Particular.with_running_total(@particulars, @opening_balance_calculated) unless @particulars.blank?
    return @particulars, @total_credit, @total_debit, @closing_balance_sorted, @opening_balance_sorted
  end

  #
  # get the particulars based on conditions
  #
  def get_particulars(page, limit = 20, date_from_ad = nil, date_to_ad = nil, no_pagination = false, lazy_load)
    particulars = @ledger.particulars.complete.by_branch_fy_code(branch_id, fy_code)
    particulars = particulars.find_by_date_range(date_from_ad, date_to_ad) if date_from_ad.present? && date_to_ad.present?
    particulars = particulars.where.not(hide_for_client: true) if @params[:for_client] == 1
    particulars = particulars.includes(:nepse_chalan, :voucher, :cheque_entries, :settlements, voucher: :bills) if lazy_load
    particulars = particulars.order('particulars.transaction_date ASC','particulars.created_at ASC')
    unless no_pagination
      particulars = particulars.page(page).per(limit)
    end
    particulars
  end

  #
  # get the carryover balance for the current page except 0
  #
  def opening_balance_for_page(opening_balance, page, date_from_ad = nil, date_to_ad = nil)
    # raw sql can be potentially dangerous and memory leakage point
    # need to make sure this has proper binding

    additional_condition = ""
    if branch_id == 0
      additional_condition = "fy_code = #{fy_code}"
    else
      additional_condition = "branch_id = #{branch_id} AND fy_code = #{fy_code}"
    end

    if date_from_ad.present? && date_to_ad.present?
      query = "SELECT SUM(subquery.amount) FROM (SELECT ( CASE WHEN transaction_type = 0 THEN amount ELSE amount * -1 END ) as amount FROM particulars WHERE ledger_id = #{@ledger.id} AND particular_status = 1 AND #{additional_condition } AND transaction_date BETWEEN '#{date_from_ad}' AND '#{date_to_ad}' ORDER BY transaction_date ASC, created_at ASC LIMIT #{20*page}) AS subquery;"
    else
      query = "SELECT SUM(subquery.amount) FROM (SELECT ( CASE WHEN transaction_type = 0 THEN amount ELSE amount * -1 END ) as amount FROM particulars WHERE ledger_id = #{@ledger.id} AND particular_status = 1 AND #{additional_condition } ORDER BY transaction_date ASC, created_at ASC LIMIT #{20*page}) AS subquery;"
    end
    opening_balance += ActiveRecord::Base.connection.execute(query).getvalue(0,0).to_f
    opening_balance
  end
end