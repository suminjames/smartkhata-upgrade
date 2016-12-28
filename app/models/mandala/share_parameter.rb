# == Schema Information
#
# Table name: share_parameter
#
#  id                :integer          not null, primary key
#  share_code        :string
#  share_description :string
#

class Mandala::ShareParameter < ActiveRecord::Base
  self.table_name = "share_parameter"
end
