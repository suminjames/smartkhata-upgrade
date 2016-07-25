module CommissionModule

  def get_commission_rate(amount, settlement_date)
    # As per http://merolagani.com/NewsDetail.aspx?newsID=27819, the updated commission prices as of July 25, 2016 is implemented.
    date_of_commission_rate_update = Date.parse('2016-7-25')
    if settlement_date >= date_of_commission_rate_update
      case amount
        when 0..2500
          "flat_25"
        when 2501..50000
          "0.60"
        when 50001..500000
          "0.55"
        when 500001..2000000
          "0.50"
        when 2000001..10000000
          "0.45"
        else # >= 10000001
          "0.40"
      end
    else
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
  end

  def get_commission(amount, settlement_date)
    commission_rate = get_commission_rate(amount, settlement_date)
    get_commission_by_rate(commission_rate, amount)
  end

  def get_commission_by_rate(commission_rate, amount)
    if (commission_rate == "flat_25")
      return 25
    else
      return amount * commission_rate.to_f * 0.01
    end
  end
end
