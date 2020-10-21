class Files::PurchaseController < ApplicationController
  before_action -> {authorize self}

  def new
  end

  def import
    # authorize self
    @file = params[:file]

    if @file.nil?
      flash.now[:error] = "Please Upload a valid file"
      @error = true
    else
      begin
        xlsx = Roo::Spreadsheet.open(@file, extension: :xlsx)
      rescue Zip::Error
        xlsx = Roo::Spreadsheet.open(@file)
      end

      # @x = Date.parse(xlsx.sheet(0).row(5)[9].tr('()',""))
      @x = []
      (5..(xlsx.sheet(0).last_row)).each do |i|
        break if xlsx.sheet(0).row(i)[0].nil?
      end
    end
  end
end
