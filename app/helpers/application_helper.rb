module ApplicationHelper
	def link_to_add_fields(name, f, association)
		new_object = 	f.object.send(association).klass.new
		id = new_object.object_id
		fields = f.fields_for(association, new_object, child_index: id) do |builder|
			render(association.to_s.singularize + "_fields" , f: builder)
		end
		link_to(name, '#', class: "add_fields",  data:  {id: id, fields: fields.gsub("\n", "")})
	end


	# get fy code based on current year
	# TODO modify the method to return based on fiscal years
	def get_fy_code
		@cal = NepaliCalendar::Calendar.new
		date = Date.today
		# grab the last 2 digit of year
		date_bs = @cal.ad_to_bs(date.year, date.month, date.day).year.to_s[2..-1]
		(date_bs + (date_bs.to_i+1).to_s).to_i
	end


	# get a unique bill number based on fiscal year
	def get_bill_number

		bill = Bill.where(fy_code: get_fy_code).last

		# initialize the bill with 1 if no bill is present
		if bill.nil?
			1
		else
			# increment the bill number
			bill.bill_number + 1
		end
	end

end
