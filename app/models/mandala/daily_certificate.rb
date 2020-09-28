# == Schema Information
#
# Table name: daily_certificate
#
#  id                            :integer          not null, primary key
#  transaction_no                :string
#  certificate_no                :string
#  kitta_no_from                 :string
#  kitta_no_to                   :string
#  share_holder                  :string
#  total                         :string
#  name_transfer_date            :string
#  name_transfer_receipt_date    :string
#  client_certificate_issue_date :string
#  fiscal_year                   :string
#  transaction_type              :string
#

class Mandala::DailyCertificate < ActiveRecord::Base
  self.table_name = "daily_certificate"
end
