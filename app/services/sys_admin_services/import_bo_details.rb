class SysAdminServices::ImportBoDetails < ImportFile
  include ApplicationHelper

  def process
    open_file(@file)
    unless @error_message
      ActiveRecord::Base.transaction do
        @processed_data.each do |hash|
          client_account = ClientAccount.find_by(boid: hash['boid']) || ClientAccount.new
          client_account.attributes = hash
          client_account.skip_validation_for_system = true
          client_account.save!
        end
      end
    end
  end
end
