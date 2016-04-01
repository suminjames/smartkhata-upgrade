desc "Update Prices"
task :update_isin_prices => :environment do
  # TODO: Scrape individual pages and find the last traded price of each isin. Currently, scraping of the last traded price of companies that had trading in the last day is only done.

  require 'nokogiri'
  require 'open-uri'

  def get_only_isin_price(details)
    details.select{|i| (i[:company] != "" && i[:max] != "")}
  end

  def get_isin_price
    continue = true
    count = 1
    past_details = []
    final_details = []
    while continue do
      url = "http://www.nepalstock.com.np/main/todays_price/index/#{count}/stock-name/asc/"
      count += 1

      doc = Nokogiri::HTML(open(url))
      date = Date.parse(doc.css("#date").first.text.split(" ")[2]).to_date
      rows = doc.search('//tr');
      details = []
      details = rows.collect do |row|
        detail = {}
        [
          [:company, 'td[2]/text()'],
          [:number_transaction, 'td[3]/text()'],
          [:max, 'td[4]/text()'],
          [:min, 'td[5]/text()'],
          [:closing, 'td[6]/text()'],
          [:traded, 'td[7]/text()'],
          [:amount, 'td[8]/text()'],
          [:last, 'td[9]/text()'],
          [:difference, 'td[10]/text()'],
          [:isin, 'td[2]/text()'],
        ].each do |name, xpath|
          detail[name] = row.at_xpath(xpath).to_s.strip
        end
        detail[:date] = date
        detail
      end
      continue = false if( details == past_details  || count > 15)
      if (details == past_details || count > 15 )
        continue = false
      else
        past_details = details
        final_details = final_details + details
      end
    end
    get_only_isin_price(final_details)
  end

  price   =  get_isin_price

  price.each do |x|
  	record = IsinInfo.where(company: x[:company]).first_or_create
		record.update( max: x[:max],
			min: x[:min],
			last_price: x[:last])

    # daily_record = IsinDailyPrice.where(company: x[:company], date: x[:date]).first_or_create
    # daily_record.update(
    #   number_transaction: x[:number_transaction],
    #   max: x[:max],
    #   min: x[:min],
    #   closing: x[:closing],
    #   traded: x[:traded],
    #   amount: x[:amount],
    #   difference: x[:difference],
    #   last: x[:last]
    #   )
  end
  puts "#{Time.now.to_s} : Successfully updated prices"

end
