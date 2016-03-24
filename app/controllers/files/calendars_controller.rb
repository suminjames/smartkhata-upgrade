class Files::CalendarsController < ApplicationController
  def new
    # new
  end

  def import
    # authorize self
    @file = params[:file];

    if @file == nil
      flash.now[:error] = "Please Upload a valid file"
      @error = true
      return
    else
      begin
        xlsx = Roo::Spreadsheet.open(@file, extension: :xlsx)
      rescue Zip::Error
        xlsx = Roo::Spreadsheet.open(@file)
      end
    end

    #TODO:
    # - Grab the last modified timestamp of the file uploaded
    # - Check the file upload date (different from modified timestamp of the file)

    from_date_bs = "2072-01-01"
    to_date_bs = "2072-12-30"
    from_date_ad = bs_to_ad(from_date_bs)
    to_date_ad = bs_to_ad(to_date_bs)

		@cal = NepaliCalendar::Calendar.new
    ad_date = "2015-06-12"
		ad_date = Date.parse(ad_date.to_s)
    puts "FUCK IT"
		# puts @cal.ad_to_bs(ad_date.year, ad_date.month, ad_date.day)

    abort(@cal.ad_to_bs("2015", "06", "15").to_s)

    from_date_ad.upto(to_date_ad) do |ad_date|
      p ad_date
      bs_date = ad_to_bs(ad_date)
      p bs_date
      hash = { }
      unless date_already_in_db (bs_date)
        p bs_date
        p bs_date.year
        p bs_date.month
        p bs_date.day
        hash[:year] = bs_date.year
        hash[:month] =  bs_date.month
        hash[:day] = bs_date.day
        hash[:date_type] = 'x'
        if ad_date.saturday?
          hash[:date_type] = 'Saturday'
          # hash[:remarks]: 'Remarks',
          hash[:is_holiday] = true
        end
        Calendar.create(hash)
      end
    end

    # Iterate through the rows of the spreadsheet.
    count = 0
    xlsx.sheet(0).each(
    year: 'Year',
    month: 'Month',
    day: 'Day',
    date_type: 'Type',
    remarks: 'Remarks',
    ) do |hash|
      #The column headers are at row 3. So skip those 3 rows.
      if count > 3
        date =  Date.parse(hash[:year].to_i.to_s + "-"  + hash[:month].to_i.to_s + "-" + hash[:day].to_i.to_s)
        unless date_already_in_db (date)
          hash[:is_holiday] = true
          Calendar.create(hash)
        end
      end
      count += 1
    end
  end

  # Checks the passed date against the 'Calendars' table in the database
  def date_already_in_db (date)
    Calendar.where(year: date.year, month: date.month, day: date.day).count != 0
  end
end

