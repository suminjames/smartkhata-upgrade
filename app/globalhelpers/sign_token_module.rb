module SignTokenModule
  def signed_data(data, pkey_pem)
    digest    = OpenSSL::Digest::SHA256.new
    pkey      = OpenSSL::PKey::RSA.new(pkey_pem)
    pkey.sign(digest, data)
  end

  def nchl_private_key
    pkcs = OpenSSL::PKCS12.new(File.read("config/trishakti.pfx"), Rails.application.secrets.nchl_passphrase)
    pkcs.key.to_pem
  end

  def get_signed_token data
    signed_key       = signed_data(data, nchl_private_key)
    Base64.encode64(signed_key)
  end

end
