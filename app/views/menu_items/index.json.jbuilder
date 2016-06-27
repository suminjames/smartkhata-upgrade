json.array!(@menu_items) do |menu_item|
  json.extract! menu_item, :id, :name, :path, :hide_on_main_navigation, :references, :code
  json.url menu_item_url(menu_item, format: :json)
end
