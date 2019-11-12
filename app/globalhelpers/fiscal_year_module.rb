module FiscalYearModule
  @@fiscal_year_breakpoint = [
      [6869, Date.parse('2011-7-17'), Date.parse('2012-7-15')],
      [6970, Date.parse('2012-7-16'), Date.parse('2013-7-15')],
      [7071, Date.parse('2013-7-16'), Date.parse('2014-7-16')],
      [7172, Date.parse('2014-7-17'), Date.parse('2015-7-15')],
      [7273, Date.parse('2015-7-16'), Date.parse('2016-7-15')],
      [7374, Date.parse('2016-7-16'), Date.parse('2017-7-15')],
      [7475, Date.parse('2017-7-16'), Date.parse('2018-7-16')],
      [7576, Date.parse('2018-7-17'), Date.parse('2019-7-16')],
      [7677, Date.parse('2019-7-17'), Date.parse('2020-7-15')],
      [7778, Date.parse('2020-7-16'), Date.parse('2021-7-15')],
      [7879, Date.parse('2021-7-16'), Date.parse('2022-7-16')],
      [7980, Date.parse('2022-7-17'), Date.parse('2023-7-16')],
  ]

  @@fiscal_year_mapping = {
      '2068/2069' => 6869,
      '2069/2070' => 6970,
      '2070/2071' => 7071,
      '2071/2072' => 7172,
      '2072/2073' => 7273,
      '2073/2074' => 7374,
      '2074/2075' => 7475,
      '2075/2076' => 7576,
      '2076/2077' => 7677,
  }


  def get_fiscal_breakpoint
    return @@fiscal_year_breakpoint
  end

  def available_fy_codes
    return @@fiscal_year_breakpoint.map { |row| row[0] }
  end

  def get_previous_fy_code fy_code = nil
    fy_code ||= get_fy_code
    fy_codes =  available_fy_codes
    index = fy_codes.index(fy_code)
    if index && (index != 0)
      return fy_codes[index - 1]
    end
  end

  def get_next_fy_code fy_code = nil
    fy_code ||= get_fy_code
    fy_codes =  available_fy_codes
    index = fy_codes.index(fy_code)
    if index && (index != fy_codes.size-1)
      return fy_codes[index + 1]
    end
  end

  # Get fy code based on current year
  # TODO modify the method to return based on fiscal years
  def get_fy_code(date = Date.today)
    fiscal_year_breakpoint_single = fiscal_year_breakpoint_single(date: date)
    return fiscal_year_breakpoint_single[0] if fiscal_year_breakpoint_single.present?
    return
  end

  #
  # get specific fy code breakpoint
  #
  def fiscal_year_breakpoint_single(attrs = {})
    date = attrs[:date]
    fy_code = attrs[:fy_code]
    fiscal_year_breakpoint = get_fiscal_breakpoint
    fiscal_year_breakpoint.each do |fiscal|
      if date.present?
        if date >= fiscal[1] && date <= fiscal[2]
          return fiscal
        end
      else
        if fy_code == fiscal[0]
          return fiscal
        end
      end
    end

    return
  end

  #
  # get first day of a fiscal year
  #
  def fiscal_year_first_day(fy_code = UserSession.selected_fy_code)
    fiscal_year_breakpoint_single = fiscal_year_breakpoint_single(fy_code: fy_code)
    return fiscal_year_breakpoint_single[1] if fiscal_year_breakpoint_single.present?
    return Time.now.to_date
  end

  #
  # get last day of a fiscal year
  #
  def fiscal_year_last_day(fy_code = UserSession.selected_fy_code)
    fiscal_year_breakpoint_single = fiscal_year_breakpoint_single(fy_code: fy_code)
    return fiscal_year_breakpoint_single[2] if fiscal_year_breakpoint_single.present?
    return Time.now.to_date
  end


  def date_valid_for_fy_code(date, fy_code=UserSession.selected_fy_code)
    fy_code_date = nil
    fiscal_year_breakpoint = get_fiscal_breakpoint
    fiscal_year_breakpoint.each do |fiscal|
      if fy_code == fiscal[0]
        fy_code_date = fiscal
      end
    end

    if fy_code_date.present?
      return true if date >= fy_code_date[1] && date <= fy_code_date[2]
    end
    false
  end

  def get_fy_code_from_fiscal_year(fiscal_year)
    @@fiscal_year_mapping[fiscal_year]
  end

  def get_fiscal_year_from_fycode(fycode)
    fymapping = @@fiscal_year_mapping.detect{|x,v| v == fycode}
    fymapping[0] if fymapping
  end

  # get list of fiscal years after each date
  # exclude true will get next fiscal years
  def get_full_fy_codes_after_date(date, exclude = false)
    fiscal_year_breakpoint_single = fiscal_year_breakpoint_single(date: date)
    fy_code =  fiscal_year_breakpoint_single[0]
    fy_codes = available_fy_codes
    index = fy_codes.find_index(fy_code.to_i)
    if index
      if exclude
        return fy_codes[(index +1) .. -1]
      else
        return fy_codes[index .. -1]
      end
    end
  end

end

# # code kept for future reference
# module Foo
#   def self.included base
#     base.send :include, InstanceMethods
#     base.extend ClassMethods
#   end
#
#   module InstanceMethods
#     def bar1
#       'bar1'
#       # self.class.bar2
#     end
#   end
#
#   module ClassMethods
#     # module_function
#     def bar2
#       'bar2'
#     end
#   end
# end
#
# class Test
#   include Foo
# end
#
# puts Test.new.bar1 # => "bar1"
# puts Test.bar2 # => "bar2"