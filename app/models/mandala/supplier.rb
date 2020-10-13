# == Schema Information
#
# Table name: supplier
#
#  id               :integer          not null, primary key
#  supplier_name    :string
#  supplier_address :string
#  supplier_no      :string
#  supplier_email   :string
#  contact_person   :string
#  supplier_fax     :string
#  supplier_id      :string
#  pan_no           :string
#  vat_no           :string
#  supplier_type    :string
#  due_days         :string
#  ac_code          :string
#

class Mandala::Supplier < ApplicationRecord
  self.table_name = "supplier"
end
