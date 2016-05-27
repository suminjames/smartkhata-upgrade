class Files::CalendarsController < ApplicationController
  def new
    # new
  end

  def import
    # authorize self
    @file = params[:file]

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

    @cal =  NepaliCalendarPlus::CalendarPlus.new

    from_date_ad = @cal.bs_to_ad(2073, 1, 1)
    to_date_ad = @cal.bs_to_ad(2074, 12, 30)

    from_date_ad.upto(to_date_ad) do |ad_date|
      bs_date = @cal.ad_to_bs(ad_date.year, ad_date.month, ad_date.day)
      date_hash = { }
      unless bs_date_already_in_db? (bs_date)
        date_hash[:year] = bs_date[:year]
        date_hash[:month] =  bs_date[:month]
        date_hash[:day] = bs_date[:day]
        date_hash[:date_type] = 'x'
        date_hash[:ad_date] = ad_date.to_s
        if ad_date.saturday?
          date_hash[:date_type] = 'Saturday'
          # hash[:remarks]: 'Remarks',
          date_hash[:is_holiday] = true
        end
        Calendar.create(date_hash)
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
        # date =  Date.parse(hash[:year].to_i.to_s + "-"  + hash[:month].to_i.to_s + "-" + hash[:day].to_i.to_s)
        date =  {:year => hash[:year], :month => hash[:month], :day => hash[:day]}
        unless bs_date_already_in_db? (date)
          hash[:is_holiday] = true
          Calendar.create(hash)
        end
      end
      count += 1
    end
  end

  # Checks the passed date against the 'Calendars' table in the database
  def bs_date_already_in_db? (date)
    Calendar.where(year: date[:year], month: date[:month], day: date[:day]).count != 0
  end
end

