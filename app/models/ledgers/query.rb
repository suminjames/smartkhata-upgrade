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
    @opening_balance_calculated = @ledger.opening_balance(fy_code, branch_id) if lazy_load

    # no pagination is required for xls/pdf file generation
    if no_pagination
      page = 0
    end

    if @params[:show] == "all"
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



          if lazy_load
            # sum of total credit and debit amount
            @total_credit = @ledger.particulars.complete.by_branch_fy_code(branch_id, fy_code).find_by_date_range(date_from_ad, date_to_ad).cr.sum(:amount)
            @total_debit = @ledger.particulars.complete.by_branch_fy_code(branch_id, fy_code).find_by_date_range(date_from_ad, date_to_ad).dr.sum(:amount)

            previous_day_balance = @ledger.particulars.by_branch_fy_code(branch_id, fy_code).where('transaction_date < ?',date_from_ad).sum("CASE WHEN transaction_type = 0 THEN amount ELSE amount * -1 END", 0)

            last_day_balance = @ledger.particulars.by_branch_fy_code(branch_id, fy_code).where('transaction_date <= ?',date_to_ad).sum("CASE WHEN transaction_type = 0 THEN amount ELSE amount * -1 END", 0)


            @closing_balance_sorted = @opening_balance_calculated+ last_day_balance
            @opening_balance_sorted = @opening_balance_calculated + previous_day_balance
            @opening_balance_calculated = @opening_balance_sorted
          end
          # get the ordered particulars
          @particulars = get_particulars(@params[:page], 20, date_from_ad, date_to_ad, no_pagination, lazy_load)
        else
          @error_message = "Invalid Date"
        end
      end
    elsif !@params[:search_by]
      @particulars = get_particulars(@params[:page], 20, nil, nil, no_pagination, lazy_load)
    end
    return @particulars, @total_credit, @total_debit, @closing_balance_sorted, @opening_balance_sorted
  end


  def ledger_particulars_with_running_total(no_pagination = false)
    ledger_with_particulars(no_pagination)
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
    particulars.select("*, SUM( amount * CASE WHEN transaction_type = 0 THEN 1  ELSE -1 END)  OVER (ORDER BY transaction_date ASC, created_at ASC ) +  #{@opening_balance_calculated}  AS running_total")
  end
end
