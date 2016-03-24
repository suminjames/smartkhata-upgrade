class ShareTransaction < ActiveRecord::Base
	belongs_to :bill
	belongs_to :isin_info
	belongs_to :client_account
	enum transaction_type: [ :buy, :sell ]

	# instead of deleting, indicate the user requested a delete & timestamp it
 def soft_delete
	 update_attribute(:deleted_at, Time.current)
 end

 def soft_undelete
	 update_attribute(:deleted_at, nil)
 end 
end
