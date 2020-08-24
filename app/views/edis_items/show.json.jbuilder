json.partial! 'edis_items/show', edis_item: @edis_item
json.splitted_records do
  if @edis_item.splitted_records.blank?
    json.null! # or json.nil!
  else
    json.array! @edis_item.splitted_records, partial: 'edis_items/show', as: :edis_item
  end
end
