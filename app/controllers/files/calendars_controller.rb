class Files::CalendarsController < ApplicationController
  before_action -> {authorize self}

  def new
  end

  def import
    # authorize self
    @file = params[:file]

    if @file.nil?
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

    # Iterate through the rows of the spreadsheet.
    count = 0
    xlsx.sheet(0).each(
      year: 'Year',
      month: 'Month',
      day: 'Day',
      is_holiday: 'Is_Holiday',
      holiday_type: 'Holiday_Type',
      is_trading_day: 'Is_Trading_Day',
      remarks: 'Remarks'
    ) do |xls_row_hash|
      # Skip header row
      if count.positive?
        calendar_date_hash = {}
        calendar_date_hash[:bs_date] = xls_row_hash[:year].to_i.to_s + '-' + xls_row_hash[:month].to_i.to_s + '-' + xls_row_hash[:day].to_i.to_s
        calendar_date_hash[:ad_date] = bs_to_ad(xls_row_hash[:year].to_i.to_s + '-' + xls_row_hash[:month].to_i.to_s + '-' + xls_row_hash[:day].to_i.to_s)
        calendar_date_hash[:is_holiday] = xls_row_hash[:is_holiday].casecmp('TRUE').zero?
        calendar_date_hash[:is_trading_day] = xls_row_hash[:is_trading_day].casecmp('TRUE').zero?
        if xls_row_hash[:holiday_type].present?
          calendar_date_hash[:holiday_type] = case xls_row_hash[:holiday_type].downcase.strip
            when 'saturday'
              Calendar.holiday_types[:saturday]
            when 'public holiday'
              Calendar.holiday_types[:public_holiday]
            when 'unforeseen holiday'
              Calendar.holiday_types[:unforeseen_holiday]
            else
              Calendar.holiday_types[:not_applicable]
                                              end
        end
        calendar_date_hash[:remarks] = xls_row_hash[:remarks]
        calendar_date_obj = Calendar.find_by(bs_date: calendar_date_hash[:bs_date])
        calendar_date_obj.update(calendar_date_hash)
      end
      count += 1
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def calendar_params
    params.require(:calendar).permit(
      :bs_date,
      :ad_date,
      :is_holiday,
      :is_trading_day,
      :holiday_type,
      :remarks
    )
  end
end
