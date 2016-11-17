module CommissionModule

  def get_commission_rate(amount, commission_info)

    details = commission_info.commission_details_array.select{ |x| amount > x.start_amount && amount <= x.limit_amount }
    if details.size != 1
      raise NotImplementedError
    end

    commission_detail = details.first
    if commission_detail.commission_rate.present?
      return commission_detail.commission_rate
    end

    return "flat_#{commission_detail.commission_amount}"


    # MasterSetup::CommissionRate.commission_rate_for(amount, transaction_date)
    # if transaction_date >= date_of_commission_rate_update
    #   case amount
    #     when 0..4166.67
    #       "flat_25"
    #     when 4166.68..50000
    #       "0.60"
    #     when 50001..500000
    #       "0.55"
    #     when 500001..2000000
    #       "0.50"
    #     when 2000001..10000000
    #       "0.45"
    #     else # >= 10000001
    #       "0.40"
    #   end
    # else
    #   case amount
    #     when 0..2500
    #       "flat_25"
    #     when 2501..50000
    #       "1"
    #     when 50001..500000
    #       "0.9"
    #     when 500001..1000000
    #       "0.8"
    #     else
    #       "0.7"
    #   end
    # end
  end

  # def get_commission_rate(amount, commission_rates)
  #
  # end

  # get the rates defined for the selected date in the database
  def get_commission_info(transaction_date)
    commission_infos = MasterSetup::CommissionInfo.where(" ? >= start_date AND ? <= end_date", transaction_date, transaction_date)
    if commission_infos.size != 1
      raise ArgumentError
    end

    commission_info = commission_info.first
    commission_info.broker_commission_rate = 100 - commission_info.nepse_commission_rate
    commission_info
  end

  def get_commission_info_with_detail(transaction_date)
    get_commission_info(transaction_date)
    commission_info.commission_details_array = commission_info.commission_details.order(:start_amount => :asc).to_a
    commission_info
  end


  def get_commission(amount, commission_info)
    commission_rate = get_commission_rate(amount, commission_info)
    get_commission_by_rate(commission_rate, amount)
  end

  def get_commission_by_rate(commission_rate, amount)
    if (commission_rate.include? "flat_")
      return commission_rate.split("flat_")[1]
    else
      return amount * commission_rate.to_f * 0.01
    end
  end


  # #
  # # get compliance fee to be paid to dhitopatra board
  # #
  # def compliance_fee(commission, transaction_date)
  #   commission * compliance_fee_rate(transaction_date)
  # end


  #
  # get broker commission( commission for the broker)
  #
  def broker_commission(commission, commission_info)
    commission * commission_info.broker_commission_rate
  end

  #
  #   get nepse commission
  #
  def nepse_commission(commission, commission_info)
    commission * commission_info.nepse_commission_rate
  end

  # #
  # # get commpliance fee rate
  # #
  # def compliance_fee_rate(transaction_date)
  #   if transaction_date >= date_of_commission_rate_update
  #     0.006
  #   else
  #     0
  #   end
  # end


  #
  # broker commission rate on total commission charged from client
  #
  def broker_commission_rate(transaction_date)
    # if transaction_date >= date_of_commission_rate_update
    #   0.8
    # else
    #   0.75
    # end

    commision_info = get_commission_info(transaction_date)
    commision_info.broker_commission_rate
  end

  #
  # nepse commission rate on total commission charged from client
  #
  def nepse_commission_rate(transaction_date)
    commision_info = get_commission_info(transaction_date)
    commision_info.nepse_commission_rate
  end



  def date_of_commission_rate_update
    # As per http://merolagani.com/NewsDetail.aspx?newsID=27819, the updated commission prices as of July 25, 2016 is implemented.
    Date.parse('2016-7-24')
  end

end
