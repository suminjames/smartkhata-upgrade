class NepseProvisionalSettlement < NepseSettlement
  has_many :sales_settlements
  has_many :edis_items, through: :sales_settlements

  def self.find_similar_to_term(search_term)
    search_term = search_term.present? ? search_term : ''
    self.where('settlement_id::TEXT like ?', "%#{search_term}%")
  end
end
