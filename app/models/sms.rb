require 'net/http'

class Sms < ActiveRecord::Base

  @tag = 'B'
  @access_code = 'test'
  @username = 'test'
  @password = 'test'

  def self.send_hello_world
    date_time = DateTime.now.to_s(:db)
    mobile_number = '9779851182852'
    msg = 'Test SMS from DIT'
    msg.gsub!(' ', '%20')

    # result = Net::HTTP.get_response(URI.parse("http://www.example.com/file.png")).body
    result = Net::HTTP.get_response(URI.parse('http://api.miracleinfo.com.np/sms/smssend.php?'+ 'tag=' + @tag + '&ac=' + @access_code + '&dt=' + date_time + '&mob=' + mobile_number + '&msg=' + msg + '&u=' + @username + '&p=' + @password)).body
    p 'Miracle YOY'
    p result


  end
end
