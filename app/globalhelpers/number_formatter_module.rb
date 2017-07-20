module NumberFormatterModule

  # Note:
  # Apparently, floats that end have pattern ****.645 don't round off (for precision 2 ) as expected.


  # Converts a number to its words equivalent Nepali/Indian style (with Lakhs instead of Millions).
  def arabic_word(decimal)
    # Calling arabic number to get the number and wording consistent with rounding off issues.
    decimal = arabic_number(decimal).gsub(',','').to_f
    paisa = (('%.2f' % decimal.round(2))[-2..-1]).to_i
    paisa_formatted = "%02d" % paisa
    word = decimal.to_f.to_words
    if word.kind_of?(Array)
      word_before_decimal = word[0]
      word_before_decimal = (word_before_decimal.sub! 'And', '') || word_before_decimal
      word_before_decimal = "#{word_before_decimal} Rupees"
      word_after_decimal = "And #{paisa_formatted}/100" if paisa > 0
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

  def monetary_decimal(decimal)
    '%.2f' % decimal.to_f.round(2)
  end

  # This method is relevant to numbers other than monetary numbers like quantity.
  # The return string doesn't have decimal value.
  def arabic_number_integer(decimal)
    arabic_number(decimal)[0..-4]
  end

  # If exists, strips a number of redundant zeroes after decimal.
  def strip_redundant_decimal_zeroes(number)
    number % 1 == 0 ? number.to_i : number
  end

  # # For testing  through console only.
  # def test_rounding
  #   divisor = 1000.0
  #   # number = 136584645
  #   number = 0
  #   range_diff = 1000000000
  #   (0..(number + range_diff)).each do |i|
  #     if (i.to_s)[-3..-1] == '645'
  #       j = i / divisor
  #       x = j.round(2)
  #       if (x.to_s)[-2..-1] == '64'
  #         p i
  #         p j
  #         p x
  #         p "*" * 10
  #       end
  #     end
  #   end
  # end

end
