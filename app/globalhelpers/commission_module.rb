module CommissionModule

  def get_commission_rate(amount, transaction_date)
    if transaction_date >= date_of_commission_rate_update
      if amount <= 4166.67
        "flat_25"
      elsif amount > 4166.67 && amount <= 50000
        "0.60"
      elsif amount > 50000 && amount <= 500000
        "0.55"
      elsif amount > 500000 && amount <= 2000000
        "0.50"
      elsif amount > 2000000 && amount <= 10000000
        "0.45"
      else # > 10000000
        "0.40"
      end
    else
      if amount <= 2500
        "flat_25"
      elsif amount > 2500 && amount <= 50000
        "1"
      elsif amount > 50000 && amount <= 500000
        "0.9"
      elsif amount > 500000 && amount <= 1000000
        "0.8"
      else # > 1000000
        "0.7"
      end
    end
  end

  def get_commission(amount, transaction_date)
    commission_rate = get_commission_rate(amount, transaction_date)
    get_commission_by_rate(commission_rate, amount)
  end

  def get_commission_by_rate(commission_rate, amount)
    if (commission_rate == "flat_25")
      return 25
    else
      return amount * commission_rate.to_f * 0.01
    end
  end


  # 
  # get compliance fee to be paid to dhitopatra board
  # 
  def compliance_fee(commission, transaction_date)
    commission * compliance_fee_rate(transaction_date)
  end  


  #
  # get broker commission( commission for the broker)
  #
  def broker_commission(commission, transaction_date)
    commission * broker_commission_rate(transaction_date)
  end

  #
  #   get nepse commission
  #
  def nepse_commission(commission, transaction_date)
    commission * nepse_commission_rate(transaction_date)
  end

  # 
  # get commpliance fee rate
  # 
  def compliance_fee_rate(transaction_date)
    if transaction_date >= date_of_commission_rate_update
      0.006
    else
      0
    end
  end


  #
  # broker commission rate on total commission charged from client
  #
  def broker_commission_rate(transaction_date)
    if transaction_date >= date_of_commission_rate_update
      0.8
    else
      0.75
    end
  end

  #
  # nepse commission rate on total commission charged from client
  #
  def nepse_commission_rate(transaction_date)
    if transaction_date >= date_of_commission_rate_update
      0.2
    else
      0.25
    end
  end

  def date_of_commission_rate_update
    # As per http://merolagani.com/NewsDetail.aspx?newsID=27819, the updated commission prices as of July 25, 2016 is implemented.
    Date.parse('2016-7-24')
  end

end
