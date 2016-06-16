module FiscalYearModule
  @@fiscal_year_breakpoint = [
    [7273,Date.parse('2015-7-16'), Date.parse('2016-7-15')],
    [7374,Date.parse('2016-7-16'), Date.parse('2017-7-15')],
    [7475,Date.parse('2017-7-16'), Date.parse('2018-7-15')],
    [7576,Date.parse('2018-7-16'), Date.parse('2019-7-16')],
    [7677,Date.parse('2019-7-17'), Date.parse('2020-7-15')],
    [7778,Date.parse('2020-7-16'), Date.parse('2021-7-15')],
    [7879,Date.parse('2021-7-16'), Date.parse('2022-7-16')],
    [7980,Date.parse('2022-7-17'), Date.parse('2023-7-16')],
  ]

  def get_fiscal_breakpoint
    return @@fiscal_year_breakpoint
  end

  # Get fy code based on current year
	# TODO modify the method to return based on fiscal years
	def get_fy_code
		date = Date.today
    fiscal_year_breakpoint = get_fiscal_breakpoint
    fiscal_year_breakpoint.each do |fiscal|
      if date >= fiscal[1] && date <= fiscal[2]
        return fiscal[0]
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