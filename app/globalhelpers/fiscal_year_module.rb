module FiscalYearModule
  @@fiscal_year_breakpoint = [
      [7172, Date.parse('2014-7-16'), Date.parse('2015-7-15')],
      [7273, Date.parse('2015-7-16'), Date.parse('2016-7-15')],
      [7374, Date.parse('2016-7-16'), Date.parse('2017-7-15')],
      [7475, Date.parse('2017-7-16'), Date.parse('2018-7-15')],
      [7576, Date.parse('2018-7-16'), Date.parse('2019-7-16')],
      [7677, Date.parse('2019-7-17'), Date.parse('2020-7-15')],
      [7778, Date.parse('2020-7-16'), Date.parse('2021-7-15')],
      [7879, Date.parse('2021-7-16'), Date.parse('2022-7-16')],
      [7980, Date.parse('2022-7-17'), Date.parse('2023-7-16')],
  ]

  def get_fiscal_breakpoint
    return @@fiscal_year_breakpoint
  end

  def available_fy_codes
    return @@fiscal_year_breakpoint.map { |row| row[0] }
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