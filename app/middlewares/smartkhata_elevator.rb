class SmartKhataElevator < Apartment::Elevators::Generic

  def self.excluded_subdomains
    @excluded_subdomains ||= ['www']
  end

  # @return {String} - The tenant to switch to
  def parse_tenant_name(request)
    # request is an instance of Rack::Request

    # example: look up some tenant from the db based on this request
    tenant_name = Tenant.name_from_request(request)

    if tenant_name.present?
      return tenant_name
    end


    request_subdomain = subdomain(request.host)
    # If the domain acquired is set to be excluded, set the tenant to whatever is currently
    # next in line in the schema search path.
    tenant_name = if self.class.excluded_subdomains.include?(request_subdomain)
                    'public'
                  else
                    request_subdomain
                  end
    return tenant_name
  end

  protected

  # *Almost* a direct ripoff of ActionDispatch::Request subdomain methods

  # Only care about the first subdomain for the database name
  def subdomain(host)
    subdomains(host).first
  end

  def subdomains(host)
    return [] unless named_host?(host)

    host.split('.')[0..-(Apartment.tld_length + 2)]
  end

  def named_host?(host)
    !(host.nil? || /\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/.match(host))
  end

end