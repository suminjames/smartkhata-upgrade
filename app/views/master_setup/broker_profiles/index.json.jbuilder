json.array!(@broker_profiles) do |broker_profile|
  json.extract! broker_profile, :id, :broker_name, :broker_number, :address, :dp_code, :phone_number, :fax_number, :email, :pan_number, :profile_type, :locale
  json.url broker_profile_url(broker_profile, format: :json)
end
