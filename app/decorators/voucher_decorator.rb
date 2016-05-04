class VoucherDecorator < ApplicationDecorator
  delegate_all

  def formatted_description
    final_array = []
    voucher_desc = object.desc
    arr = voucher_desc.split('|')
    # get_bill_number(arr[0].split(' Amount:')[0])

    arr.each do |bill_des|
      new_arr = bill_des.split(' Amount:')

      bill_num = new_arr[0].split('Bill No.:')[1]
      bill_num = bill_num.tr(' ','') if bill_num.present?
      final_array << [bill_num, new_arr[1]] if bill_num.present?
    end
    final_array
  end
end
