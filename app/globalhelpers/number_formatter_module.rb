module NumberFormatterModule

	# Converts a number to its words equivalent Nepali/Indian style (with Lakhs instead of Millions).
	def arabic_word(decimal)
		word = decimal.to_f.to_words
		if word.kind_of?(Array)
			word = "#{word[0]} And #{word[1]} Paisa"
		end
		word.titleize
	end

	# Similar to number_to_currency but with arabic way of comma separation.
	def arabic_number(decimal)
		decimal.to_f.round(2).to_amount
	end
end
