class Closeout < ActiveRecord::Base
  enum closeout_type: [:debit, :credit]

  # validates :employee_id, uniqueness: { scope: :area_id }
  validates :net_amount, presence: true
end
