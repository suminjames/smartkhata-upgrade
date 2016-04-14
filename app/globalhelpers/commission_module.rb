module CommissionModule

	def get_commission_rate(amount)
		case amount
			when 0..2500
				"flat_25"
			when 2501..50000
				"1"
			when 50001..500000
				"0.9"
			when 500001..1000000
				"0.8"
			else
				"0.7"
		end
	end

	def get_commission(amount)
		commission_rate = get_commission_rate(amount)
		# if (commission_rate == "flat_25")
		# 	return 25
		# else
		# 	return amount * commission_rate.to_f * 0.01
		# end
		get_commission_by_rate(commission_rate,amount)
	end

	def get_commission_by_rate(commission_rate, amount)
		if (commission_rate == "flat_25")
			return 25
		else
			return amount * commission_rate.to_f * 0.01
		end
	end
end
