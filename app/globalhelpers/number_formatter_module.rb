module NumberFormatterModule

	# Converts a number to its words equivalent Nepali/Indian style (with Lakhs instead of Millions).
	def arabic_word(decimal)
    paisa = ((decimal.to_f - decimal.to_i)*100).to_i
		word = decimal.to_f.to_words
		if word.kind_of?(Array)
      word_before_decimal = word[0].titleize

      word_before_decimal = "#{word_before_decimal.sub! 'And', ''} Rupees"
			word = "#{word_before_decimal} And #{paisa}/100 Only"
		end
		word.titleize
	end

	# Similar to number_to_currency but with arabic way of comma separation.
	def arabic_number(decimal)
		decimal.to_f.round(2).to_amount
	end
end
