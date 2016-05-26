module NumberFormatterModule

	# Converts a number to its words equivalent Nepali/Indian style (with Lakhs instead of Millions).
	def arabic_word(decimal)
    paisa = ((decimal.to_f - decimal.to_i).round(2) * 100).to_i
		word = decimal.to_f.to_words
		if word.kind_of?(Array)
      word_before_decimal = word[0].titleize
			word_before_decimal = ( word_before_decimal.sub! 'And', '' ) || word_before_decimal
      word_before_decimal = "#{word_before_decimal} Rupees"
			word_after_decimal = "And #{paisa}/100" if paisa > 0
			word = "#{word_before_decimal} #{word_after_decimal}"
		else
			word = "#{word} Rupees"
		end
		word.titleize
	end

	# Similar to number_to_currency but with arabic way of comma separation.
	# Caution: Returns 0.00 for empty decimal passed in
	def arabic_number(decimal)
		decimal.to_f.round(2).to_amount
	end
end
