data = "MERCHANTID=303,APPID=MER-303-APP-1,APPNAME=Trishakti,TXNID=8024,TXNDATE=04-02-2021,TXNCRNCY=NPR,TXNAMT=2000,REFERENCEID=1.2.4,REMARKS=123455,PARTICULARS=12345,TOKEN=TOKEN"

data_2 = "MERCHANTID=303,APPID=MER-303-APP-1,REFERENCEID=8024,TXNAMT=2000"

# Gateway URL: https://uat.connectips.com/connectipswebgw/loginpage
# Merchant id: 303
# App id :  MER-303-APP-1
# App Name: Trishakti
#
# Validation URL: https://uat.connectips.com/connectipswebws/api/creditor/validatetxn
# Username for Validation URL (Basic Auth): MER-303-APP-1
# Password (Basic Auth): Abcd@123
# Password for CREDITOR.pfx: 123

require 'openssl'
require 'pry'
require 'base64'

def signed_data(data, pkey_pem)
  digest    = OpenSSL::Digest::SHA256.new
  pkey      = OpenSSL::PKey::RSA.new(pkey_pem)
  signature = pkey.sign(digest, data)
end

def nchl_private_key
  pkcs = OpenSSL::PKCS12.new(File.read("tmp/CREDITOR.pfx"), '123')
  pkcs.key.to_pem
end

signed_key = signed_data(data_2, nchl_private_key)
base_64_encoding = Base64.encode64(signed_key)

puts base_64_encoding