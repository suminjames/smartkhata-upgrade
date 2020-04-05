require 'public_suffix'
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
    host_valid?(host) ? parse_host(host) : []
  end

  def host_valid?(host)
    !ip_host?(host) && domain_valid?(host)
  end

  def ip_host?(host)
    !/^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$/.match(host).nil?
  end

  def domain_valid?(host)
    PublicSuffix.valid?(host, ignore_private: true)
  end

  def parse_host(host)
    (PublicSuffix.parse(host, ignore_private: true).trd || '').split('.')
  end
end
