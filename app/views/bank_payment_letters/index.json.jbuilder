json.array!(@bank_payment_letters) do |bank_payment_letter|
  json.extract! bank_payment_letter, :id, :fy_code, :creator_id, :updater_id, :nepse_settlement_id, :branch_id, :voucher_id
  json.url bank_payment_letter_url(bank_payment_letter, format: :json)
end
