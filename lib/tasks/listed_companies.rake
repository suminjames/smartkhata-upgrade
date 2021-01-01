desc "Fetch Listed Companies"
task :fetch_companies => :environment do

  require 'nokogiri'
  require 'open-uri'
  require 'mechanize'

  date = Date.today

  def get_only_isin_data(details)
  	details.select{|i| (i[:company].present? && i[:isin].present? )}
  end

  def get_isin_details
    final_details = []

    mechanize = Mechanize.new
    # go to company page of nepse and grab all the companies
    page = mechanize.get('http://www.nepalstock.com.np/company')
    search_page = page.form_with(:id => 'company-filter') do |search|
      search['_limit'] = '500'
      page = search.submit
      doc = Nokogiri::HTML(page.body)

      rows = doc.search('//table/tr');
      details = []
      details = rows.collect do |row|
        detail = {}
        [
          [:company, 'td[3]/text()'],
          [:isin, 'td[4]/text()'],
          [:sector, 'td[5]/text()'],
        ].each do |name, xpath|
          detail[name] = row.at_xpath(xpath).to_s.strip
        end
        detail
      end
      final_details = final_details + details
    end

    # go to promoter share page and grab all the companies
    page = mechanize.get('http://www.nepalstock.com.np/promoter-share')
    search_page = page.form_with(:id => 'company-filter') do |search|
      search['_limit'] = '500'
      page = search.submit
      doc = Nokogiri::HTML(page.body)

      rows = doc.search('//table/tr');
      details = []
      details = rows.collect do |row|
        detail = {}
        [
          [:company, 'td[3]/text()'],
          [:isin, 'td[4]/text()'],
          [:sector, 'td[5]/text()'],
        ].each do |name, xpath|
          detail[name] = row.at_xpath(xpath).to_s.strip
        end
        detail
      end
      final_details = final_details + details
    end

    get_only_isin_data(final_details)
  end

  details =  get_isin_details
  # store all details into IsinInfo Table
  details.each do |x|
    record = IsinInfo.find_or_create_by!(isin: x[:isin]) do |isin|
      isin.company = x[:company]
      isin.sector = x[:sector]
    end
    # update the company name if not available already
    record.update( company: x[:company]) if record.company.nil?
    # update the sector if not available already
    record.update( sector: x[:sector]) if record.sector.nil? && !x[:sector].blank?
  end
  puts "#{date} : Sucessfully Fetched  Companies"
end
