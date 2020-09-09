# == Schema Information
#
# Table name: audits
#
#  id              :integer          not null, primary key
#  auditable_id    :integer
#  auditable_type  :string
#  associated_id   :integer
#  associated_type :string
#  user_id         :integer
#  user_type       :string
#  username        :string
#  action          :string
#  audited_changes :text
#  version         :integer          default(0)
#  comment         :string
#  remote_address  :string
#  request_uuid    :string
#  created_at      :datetime
#

class AuditTrail < Audited::Audit
  belongs_to :user

  def detailed_info
    info = ""
    self.audited_changes.each do |key, value|
      if (key != 'creator_id' && key != 'updater_id')
        info += "#{key}: "
        if value.is_a? Array
          info += " changed from #{(value[0].present? ? value[0] : 'nil')} to #{value[1].blank? ? 'nil' : value[1] } \n"
        else
          info += "#{value} \n"
        end
      end

    end
    info
  end
end
