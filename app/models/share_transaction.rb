class ShareTransaction < ActiveRecord::Base
	belongs_to :bill
	belongs_to :voucher
	belongs_to :isin_info
	belongs_to :client_account
	enum transaction_type: [ :buy, :sell ]

  scope :find_by_date, -> (date) { where(
    :date=> date.beginning_of_day..date.end_of_day) }
  scope :find_by_date_range, -> (date_from, date_to) { where(
      :date=> date_from.beginning_of_day..date_to.end_of_day) }
	scope :not_cancelled, -> { where(deleted_at: nil) }
	scope :cancelled, -> { where.not(deleted_at: nil) }

 def do_as_per_params (params)
  # TODO
 end

# instead of deleting, indicate the user requested a delete & timestamp it
 def soft_delete
	 update_attribute(:deleted_at, Time.current)
 end

 def soft_undelete
	 update_attribute(:deleted_at, nil)
 end
end
